import 'package:event_managment_app/providers/auth_provider.dart';
import 'package:event_managment_app/views/loginView/login.dart';
import 'package:event_managment_app/views/view_tree.dart';
import 'package:event_managment_app/widget/eventora_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Decides whether to show the startup [EventoraLoadingScreen], [ViewTree], or [Login].
///
/// **Purpose:**
/// Acts as an authentication guard at the entry of the app:
/// 1. Shows [EventoraLoadingScreen] while the app is initializing.
/// 2. Routes signed-in users to [ViewTree] and unauthenticated users to [Login].
///
/// **How it works:**
/// Uses `context.select` on [AuthProvider] to listen to [AuthProvider.isInitializing]
/// and [AuthProvider.isLoggedIn].
class AuthGate extends StatelessWidget {
  /// Creates an [AuthGate] widget.
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isInitializing = context.select<AuthProvider, bool>(
      (auth) => auth.isInitializing,
    );
    final isLoggedIn = context.select<AuthProvider, bool>(
      (auth) => auth.isLoggedIn,
    );

    if (isInitializing) {
      return const EventoraLoadingScreen(
        message: 'Welcome to Eventora',
        subtitle: 'Preparing your personalized event feed...',
      );
    }

    return isLoggedIn ? const ViewTree() : const Login();
  }
}
