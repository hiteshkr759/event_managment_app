import 'package:event_managment_app/providers/auth_provider.dart';
import 'package:event_managment_app/views/loginView/login.dart';
import 'package:event_managment_app/views/view_tree.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Decides whether to show the main app ([ViewTree]) or the [Login] screen.
///
/// **Purpose:**
/// Acts as an authentication guard at the entry of the app so unauthenticated
/// users are shown the login screen and signed-in users go straight to Home.
///
/// **How it works:**
/// Uses `context.select` on [AuthProvider] to listen specifically to the
/// [AuthProvider.isLoggedIn] boolean. Whenever the user logs in or logs out,
/// Flutter automatically rebuilds this widget and swaps between [ViewTree] and
/// [Login].
class AuthGate extends StatelessWidget {
  /// Creates an [AuthGate] widget.
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // context.select listens ONLY to `isLoggedIn`. If other fields in
    // AuthProvider change (like password visibility), AuthGate won't rebuild.
    final isLoggedIn = context.select<AuthProvider, bool>(
      (auth) => auth.isLoggedIn,
    );
    return isLoggedIn ? const ViewTree() : const Login();
  }
}
