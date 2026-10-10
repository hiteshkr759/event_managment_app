import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:event_managment_app/notifiers/profile_notifer.dart';

final ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);
final ValueNotifier<bool> authLoadingNotifier = ValueNotifier<bool>(false);
final ValueNotifier<bool> obscureLoginPasswordNotifier = ValueNotifier<bool>(
  true,
);
final ValueNotifier<bool> obscureSignUpPasswordNotifier = ValueNotifier<bool>(
  true,
);
final ValueNotifier<bool> obscureConfirmPasswordNotifier = ValueNotifier<bool>(
  true,
);

SupabaseClient get supabase => Supabase.instance.client;

void initAuth() {
  authNotifier.value = supabase.auth.currentSession != null;
  if (authNotifier.value) loadProfile(); // app opened with a saved session

  supabase.auth.onAuthStateChange.listen((data) {
    authNotifier.value = data.session != null;

    if (data.event == AuthChangeEvent.signedIn) {
      loadProfile();
    } else if (data.event == AuthChangeEvent.signedOut) {
      clearProfile();
    }
  });
}

Future<void> login(String email, String password) async {
  authLoadingNotifier.value = true;
  try {
    await supabase.auth.signInWithPassword(email: email, password: password);
  } finally {
    authLoadingNotifier.value = false;
  }
}

Future<AuthResponse> signUp(
  String email,
  String password, {
  String? fullName,
  String? phone,
}) async {
  authLoadingNotifier.value = true;
  try {
    final data = <String, dynamic>{
      if (fullName != null && fullName.trim().isNotEmpty)
        'full_name': fullName.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
    };
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: data.isEmpty ? null : data,
    );
  } finally {
    authLoadingNotifier.value = false;
  }
}

Future<void> logout() async {
  await supabase.auth.signOut();
}
