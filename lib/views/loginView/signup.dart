import 'package:event_managment_app/notifiers/auth_notifier.dart';
import 'package:event_managment_app/widget/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    void showMessage(String message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> submitSignUp() async {
      FocusScope.of(context).unfocus();
      if (!formKey.currentState!.validate()) return;

      try {
        final response = await signUp(
          emailController.text.trim(),
          passwordController.text,
          fullName: nameController.text.trim(),
          phone: phoneController.text.trim(),
        );

        if (!context.mounted) return;

        if (response.session != null) {
          // Signed in immediately; pop back so AuthGate shows ViewTree
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          showMessage(
            'Account created! Please check your email to verify your account.',
          );
          Navigator.of(context).pop();
        }
      } on AuthException catch (e) {
        showMessage(e.message);
      } catch (_) {
        showMessage('Could not create account. Please try again.');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
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
                      badgeText: 'NEW MEMBER',
                      title: 'Join Event Management',
                      subtitle:
                          'Create your account to discover featured events and activities near you.',
                      icon: Icons.celebration_rounded,
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
                              'Personal Details',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: nameController,
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              prefixIcon: Icons.person_outline,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().length < 2) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
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
                            AuthTextField(
                              controller: phoneController,
                              label: 'Phone Number (Optional)',
                              hint: '+1 234 567 8900',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                final phone = (value ?? '').trim();
                                if (phone.isEmpty) return null;
                                return RegExp(
                                      r'^\+?[0-9\s\-]{7,15}$',
                                    ).hasMatch(phone)
                                    ? null
                                    : 'Enter a valid phone number';
                              },
                            ),
                            const SizedBox(height: 14),
                            ValueListenableBuilder<bool>(
                              valueListenable: obscureSignUpPasswordNotifier,
                              builder: (context, obscure, _) {
                                return AuthTextField(
                                  controller: passwordController,
                                  label: 'Password',
                                  hint: 'At least 6 characters',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: obscure,
                                  textInputAction: TextInputAction.next,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      obscureSignUpPasswordNotifier.value =
                                          !obscure;
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            ValueListenableBuilder<bool>(
                              valueListenable: obscureConfirmPasswordNotifier,
                              builder: (context, obscure, _) {
                                return AuthTextField(
                                  controller: confirmPasswordController,
                                  label: 'Confirm Password',
                                  hint: 'Re-enter your password',
                                  prefixIcon: Icons.verified_user_outlined,
                                  obscureText: obscure,
                                  textInputAction: TextInputAction.done,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      obscureConfirmPasswordNotifier.value =
                                          !obscure;
                                    },
                                  ),
                                  validator: (value) {
                                    if (value != passwordController.text) {
                                      return 'Passwords do not match';
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
                                    onPressed: isLoading ? null : submitSignUp,
                                    icon: isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.person_add_alt_1),
                                    label: Text(
                                      isLoading
                                          ? 'Creating Account...'
                                          : 'Sign Up',
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
                          'Already have an account?',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Sign In'),
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

