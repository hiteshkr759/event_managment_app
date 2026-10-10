import 'package:event_managment_app/providers/auth_provider.dart';
import 'package:event_managment_app/views/loginView/login.dart';
import 'package:event_managment_app/views/view_tree.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.select<AuthProvider, bool>(
      (auth) => auth.isLoggedIn,
    );
    return isLoggedIn ? const ViewTree() : const Login();
  }
}
