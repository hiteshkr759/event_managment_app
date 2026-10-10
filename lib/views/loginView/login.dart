import 'package:event_managment_app/providers/auth_provider.dart';
import 'package:event_managment_app/views/loginView/signup.dart';
import 'package:event_managment_app/widget/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  Future<void> _submitLogin(BuildContext formContext) async {
    final auth = formContext.read<AuthProvider>();
    if (!(Form.maybeOf(formContext)?.validate() ?? false)) return;
    FocusScope.of(formContext).unfocus();

    try {
      await auth.signIn();
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
            content: Text('An unexpected error occurred. Please try again.'),
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
      appBar: AppBar(title: const Text('Eventora'), centerTitle: true),
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
                                controller: auth.loginEmailController,
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
                                controller: auth.loginPasswordController,
                                label: 'Password',
                                hint: 'Enter your password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: auth.obscureLoginPassword,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    auth.obscureLoginPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: auth.toggleLoginPasswordVisibility,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
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
                                      : () => _submitLogin(formContext),
                                  icon: auth.isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.login_rounded),
                                  label: Text(
                                    auth.isLoading ? 'Signing In...' : 'Sign In',
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
      ),
    );
  }
}
