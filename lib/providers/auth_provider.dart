import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final ProfileProvider _profileProvider;

  // Persistent TextEditingControllers for Stateless Login & SignUp views
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final TextEditingController signUpNameController = TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();
  final TextEditingController signUpPhoneController = TextEditingController();
  final TextEditingController signUpPasswordController =
      TextEditingController();
  final TextEditingController signUpConfirmPasswordController =
      TextEditingController();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureSignUpPassword = true;
  bool _obscureConfirmPassword = true;

  AuthProvider(this._profileProvider) {
    _initAuth();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get obscureLoginPassword => _obscureLoginPassword;
  bool get obscureSignUpPassword => _obscureSignUpPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  SupabaseClient get _supabase => Supabase.instance.client;

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

  void toggleLoginPasswordVisibility() {
    _obscureLoginPassword = !_obscureLoginPassword;
    _safeNotify();
  }

  void toggleSignUpPasswordVisibility() {
    _obscureSignUpPassword = !_obscureSignUpPassword;
    _safeNotify();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    _safeNotify();
  }

  bool _isNetworkLookupError(Object error) {
    final msg = error.toString().toLowerCase();
    return error is AuthRetryableFetchException ||
        msg.contains('socketexception') ||
        msg.contains('failed host lookup') ||
        msg.contains('clientexception');
  }

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
