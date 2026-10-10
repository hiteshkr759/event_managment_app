import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final ProfileProvider _profileProvider;

  // Persistent FormKeys & TextEditingControllers for Stateless Login & SignUp views
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
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

  AuthProvider({required this._profileProvider}) {
    _initAuth();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get obscureLoginPassword => _obscureLoginPassword;
  bool get obscureSignUpPassword => _obscureSignUpPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  SupabaseClient get _supabase => Supabase.instance.client;

  void _initAuth() {
    _isLoggedIn = _supabase.auth.currentSession != null;
    if (_isLoggedIn) {
      _profileProvider.loadProfile();
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      _isLoggedIn = data.session != null;
      if (data.event == AuthChangeEvent.signedIn) {
        _profileProvider.loadProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _profileProvider.clearProfile();
      }
      notifyListeners();
    });
  }

  void toggleLoginPasswordVisibility() {
    _obscureLoginPassword = !_obscureLoginPassword;
    notifyListeners();
  }

  void toggleSignUpPasswordVisibility() {
    _obscureSignUpPassword = !_obscureSignUpPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  Future<void> signIn() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.auth.signInWithPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
      );
      loginPasswordController.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResponse> registerAccount() async {
    _isLoading = true;
    notifyListeners();
    try {
      final fullName = signUpNameController.text.trim();
      final phone = signUpPhoneController.text.trim();
      final data = <String, dynamic>{
        if (fullName.isNotEmpty) 'full_name': fullName,
        if (phone.isNotEmpty) 'phone': phone,
      };
      final response = await _supabase.auth.signUp(
        email: signUpEmailController.text.trim(),
        password: signUpPasswordController.text,
        data: data.isEmpty ? null : data,
      );
      signUpPasswordController.clear();
      signUpConfirmPasswordController.clear();
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
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
