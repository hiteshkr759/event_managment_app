import 'package:event_managment_app/notifiers/auth_notifier.dart';
import 'package:event_managment_app/views/loginView/login.dart';
import 'package:event_managment_app/views/view_tree.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: authNotifier,
      builder: (context, isLoggedIn, _) {
        return isLoggedIn ? const ViewTree() : const Login();
      },
    );
  }
}
