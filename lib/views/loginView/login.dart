import 'package:event_managment_app/notifiers/auth_notifier.dart';
import 'package:event_managment_app/views/loginView/signup.dart';
import 'package:event_managment_app/widget/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    void showMessage(String message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> submitLogin() async {
      FocusScope.of(context).unfocus();
      if (!formKey.currentState!.validate()) return;

      try {
        await login(emailController.text.trim(), passwordController.text);
      } on AuthException catch (e) {
        showMessage(e.message);
      } catch (_) {
        showMessage('An unexpected error occurred. Please try again.');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Event Management'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeaderBanner(
                      badgeText: 'WELCOME BACK',
                      title: 'Discover Amazing Events',
                      subtitle:
                          'Sign in to explore featured events, nearby meetups, and manage your bookings.',
                      icon: Icons.event_available_rounded,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign In to Your Account',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: emailController,
                              label: 'Email Address',
                              hint: 'you@example.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                final email = (value ?? '').trim();
                                if (email.isEmpty || !email.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            ValueListenableBuilder<bool>(
                              valueListenable: obscureLoginPasswordNotifier,
                              builder: (context, obscure, _) {
                                return AuthTextField(
                                  controller: passwordController,
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: obscure,
                                  textInputAction: TextInputAction.done,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      obscureLoginPasswordNotifier.value =
                                          !obscure;
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 22),
                            ValueListenableBuilder<bool>(
                              valueListenable: authLoadingNotifier,
                              builder: (context, isLoading, _) {
                                return SizedBox(
                                  height: 48,
                                  child: FilledButton.icon(
                                    onPressed: isLoading ? null : submitLogin,
                                    icon: isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.login_rounded),
                                    label: Text(
                                      isLoading ? 'Signing In...' : 'Sign In',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SignUp(),
                              ),
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
