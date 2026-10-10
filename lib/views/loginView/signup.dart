import 'package:event_managment_app/providers/auth_provider.dart';
import 'package:event_managment_app/widget/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  Future<void> _submitSignUp(BuildContext formContext) async {
    final auth = formContext.read<AuthProvider>();
    if (!(Form.maybeOf(formContext)?.validate() ?? false)) return;
    FocusScope.of(formContext).unfocus();

    try {
      final response = await auth.registerAccount();
      if (!formContext.mounted) return;

      if (response.session != null) {
        Navigator.of(formContext).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(formContext).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created! Please check your email to verify your account.',
            ),
          ),
        );
        Navigator.of(formContext).pop();
      }
    } on AuthException catch (e) {
      if (formContext.mounted) {
        ScaffoldMessenger.of(
          formContext,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (formContext.mounted) {
        ScaffoldMessenger.of(formContext).showSnackBar(
          const SnackBar(
            content: Text('Could not create account. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Builder(
                  builder: (formContext) => Column(
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
                                controller: auth.signUpNameController,
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
                                controller: auth.signUpEmailController,
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
                                controller: auth.signUpPhoneController,
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
                              AuthTextField(
                                controller: auth.signUpPasswordController,
                                label: 'Password',
                                hint: 'At least 6 characters',
                                prefixIcon: Icons.lock_outline,
                                obscureText: auth.obscureSignUpPassword,
                                textInputAction: TextInputAction.next,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    auth.obscureSignUpPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: auth.toggleSignUpPasswordVisibility,
                                ),
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              AuthTextField(
                                controller: auth.signUpConfirmPasswordController,
                                label: 'Confirm Password',
                                hint: 'Re-enter your password',
                                prefixIcon: Icons.verified_user_outlined,
                                obscureText: auth.obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    auth.obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: auth.toggleConfirmPasswordVisibility,
                                ),
                                validator: (value) {
                                  if (value !=
                                      auth.signUpPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                height: 48,
                                child: FilledButton.icon(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () => _submitSignUp(formContext),
                                  icon: auth.isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.person_add_alt_1),
                                  label: Text(
                                    auth.isLoading
                                        ? 'Creating Account...'
                                        : 'Sign Up',
                                  ),
                                ),
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
      ),
    );
  }
}
