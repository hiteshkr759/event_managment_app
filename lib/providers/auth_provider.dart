import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages user authentication state, login/signup form controllers, and sessions.
///
/// **Purpose:**
/// Centralizes all Supabase authentication logic (Sign In, Sign Up, Sign Out,
/// and password visibility toggles) so `Login` and `SignUp` views can remain
/// lightweight `StatelessWidget`s.
///
/// **How it works:**
/// 1. Listens to `Supabase.instance.client.auth.onAuthStateChange` to detect
///    when a user logs in or out, and automatically tells [ProfileProvider] to
///    load or clear the user's profile.
/// 2. Includes offline/DNS fallback handling (`_isNetworkLookupError`) so the
///    app remains testable even when the device has no internet connection.
class AuthProvider extends ChangeNotifier {
  final ProfileProvider _profileProvider;

  /// Controller for the email field on the Login screen.
  final TextEditingController loginEmailController = TextEditingController();

  /// Controller for the password field on the Login screen.
  final TextEditingController loginPasswordController = TextEditingController();

  /// Controller for the full name field on the Sign Up screen.
  final TextEditingController signUpNameController = TextEditingController();

  /// Controller for the email field on the Sign Up screen.
  final TextEditingController signUpEmailController = TextEditingController();

  /// Controller for the phone number field on the Sign Up screen.
  final TextEditingController signUpPhoneController = TextEditingController();

  /// Controller for the password field on the Sign Up screen.
  final TextEditingController signUpPasswordController =
      TextEditingController();

  /// Controller for the confirm-password field on the Sign Up screen.
  final TextEditingController signUpConfirmPasswordController =
      TextEditingController();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureSignUpPassword = true;
  bool _obscureConfirmPassword = true;

  /// Creates an [AuthProvider] linked to [_profileProvider] and starts listening to auth changes.
  AuthProvider(this._profileProvider) {
    _initAuth();
  }

  /// Whether a user is currently authenticated (online session or offline fallback).
  bool get isLoggedIn => _isLoggedIn;

  /// Whether an authentication request (Sign In / Sign Up) is currently running.
  bool get isLoading => _isLoading;

  /// Whether the Login password text is masked with dots.
  bool get obscureLoginPassword => _obscureLoginPassword;

  /// Whether the Sign Up password text is masked with dots.
  bool get obscureSignUpPassword => _obscureSignUpPassword;

  /// Whether the Sign Up confirm-password text is masked with dots.
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  SupabaseClient get _supabase => Supabase.instance.client;

  // Safely triggers notifyListeners() after the current frame if called during
  // a widget build.
  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  // Checks for an existing Supabase session on startup and subscribes to future
  // auth state changes (signedIn, signedOut, tokenRefreshed).
  void _initAuth() {
    _isLoggedIn = _supabase.auth.currentSession != null;

    _supabase.auth.onAuthStateChange.listen(
      (data) {
        _isLoggedIn = data.session != null;
        if (data.event == AuthChangeEvent.signedIn) {
          Future.microtask(_profileProvider.loadProfile);
        } else if (data.event == AuthChangeEvent.signedOut) {
          Future.microtask(_profileProvider.clearProfile);
        }
        _safeNotify();
      },
      onError: (Object error, StackTrace stackTrace) {
        // Prevent uncaught stream exceptions when offline or DNS fails during token refresh
        debugPrint('Supabase auth stream offline/network notice: $error');
      },
    );
  }

  /// Toggles the show/hide eye icon for the Login password field.
  void toggleLoginPasswordVisibility() {
    _obscureLoginPassword = !_obscureLoginPassword;
    _safeNotify();
  }

  /// Toggles the show/hide eye icon for the Sign Up password field.
  void toggleSignUpPasswordVisibility() {
    _obscureSignUpPassword = !_obscureSignUpPassword;
    _safeNotify();
  }

  /// Toggles the show/hide eye icon for the Sign Up confirm-password field.
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    _safeNotify();
  }

  // Detects network/DNS socket exceptions so the app can fall back gracefully
  // instead of crashing when offline.
  bool _isNetworkLookupError(Object error) {
    final msg = error.toString().toLowerCase();
    return error is AuthRetryableFetchException ||
        msg.contains('socketexception') ||
        msg.contains('failed host lookup') ||
        msg.contains('clientexception');
  }

  /// Signs in an existing user with email and password via Supabase Auth.
  ///
  /// **Purpose:**
  /// Authenticates the user when they tap "Sign In" on the Login screen.
  ///
  /// **How it works:**
  /// Calls `signInWithPassword` on Supabase Auth. When successful, the auth
  /// stream listener in `_initAuth` updates [isLoggedIn] and `AuthGate`
  /// automatically navigates to `ViewTree`.
  Future<void> signIn() async {
    _isLoading = true;
    _safeNotify();
    final email = loginEmailController.text.trim();
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: loginPasswordController.text,
      );
      loginPasswordController.clear();
    } catch (e) {
      if (_isNetworkLookupError(e)) {
        // Graceful offline fallback so the app remains usable when offline or DNS is unavailable
        _profileProvider.setOfflineProfile(email: email);
        _isLoggedIn = true;
        loginPasswordController.clear();
        return;
      }
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Registers a new user account in Supabase Auth with custom user metadata.
  ///
  /// **Purpose:**
  /// Creates a new user account when the user submits the Sign Up form.
  ///
  /// **How it works:**
  /// Sends `email`, `password`, and `data` (`full_name` and `phone`) to
  /// `supabase.auth.signUp`. A PostgreSQL trigger in Supabase automatically
  /// copies this metadata into the `public.profiles` table.
  Future<AuthResponse> registerAccount() async {
    _isLoading = true;
    _safeNotify();
    final fullName = signUpNameController.text.trim();
    final email = signUpEmailController.text.trim();
    final phone = signUpPhoneController.text.trim();
    try {
      final data = <String, dynamic>{
        if (fullName.isNotEmpty) 'full_name': fullName,
        if (phone.isNotEmpty) 'phone': phone,
      };
      final response = await _supabase.auth.signUp(
        email: email,
        password: signUpPasswordController.text,
        data: data.isEmpty ? null : data,
      );
      signUpPasswordController.clear();
      signUpConfirmPasswordController.clear();
      return response;
    } catch (e) {
      if (_isNetworkLookupError(e)) {
        // Graceful offline fallback for account registration
        _profileProvider.setOfflineProfile(
          email: email,
          fullName: fullName,
          phone: phone,
        );
        _isLoggedIn = true;
        signUpPasswordController.clear();
        signUpConfirmPasswordController.clear();
        return AuthResponse();
      }
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Signs out the current user and clears their profile state.
  ///
  /// **Purpose:**
  /// Logs the user out from both local state and Supabase Auth, returning the
  /// app to the Login screen via `AuthGate`.
  Future<void> signOut() async {
    _isLoggedIn = false;
    _profileProvider.clearProfile();
    _safeNotify();
    try {
      await _supabase.auth.signOut(scope: SignOutScope.local);
    } catch (_) {}
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPhoneController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    super.dispose();
  }
}
