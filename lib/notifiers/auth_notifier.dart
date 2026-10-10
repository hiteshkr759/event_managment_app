import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:event_managment_app/notifiers/profile_notifer.dart';

// const _key = 'isLoggedIn';

final ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);

SupabaseClient get supabase => Supabase.instance.client;

// void initAuth() {
//   // Restored session (Supabase saves it on the device and refreshes it)
//   authNotifier.value = supabase.auth.currentSession != null;

//   // Keeps authNotifier in sync on login, logout, and token expiry
//   supabase.auth.onAuthStateChange.listen((data) {
//     authNotifier.value = data.session != null;
//   });
// }

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

// Call once in main() before runApp
// Future<void> loadLoginState() async {
//   final prefs = await SharedPreferences.getInstance();
//   authNotifier.value = prefs.getBool(_key) ?? false;
// }

Future<void> login(String email, String password) async {
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setBool(_key, true);
  // authNotifier.value = true;
  await supabase.auth.signInWithPassword(email: email, password: password);
}

Future<void> signUp(String email, String password) async {
  await supabase.auth.signUp(email: email, password: password);
}

Future<void> logout() async {
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setBool(_key, false);
  // authNotifier.value = false;
  await supabase.auth.signOut();
}
