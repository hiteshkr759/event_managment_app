import 'package:event_managment_app/notifiers/auth_notifier.dart';
import 'package:event_managment_app/notifiers/profile_notifer.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Profile?>(
      valueListenable: profileNotifier,
      builder: (context, profile, _) => profile == null
          ? const Center(child: CircularProgressIndicator())
          : _ProfileForm(profile: profile),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  final Profile profile;
  const _ProfileForm({required this.profile});

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    isDense: false,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: profile.fullName ?? '');
    final email = TextEditingController(text: profile.email);
    final phone = TextEditingController(text: profile.phone ?? '');

    void toast(String m) =>
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

    Future<void> save() async {
      FocusScope.of(context).unfocus();
      if (!formKey.currentState!.validate()) return;
      try {
        await updateProfile(
          fullName: name.text.trim(),
          phone: phone.text.trim(),
          bio: profile.bio,
          role: profile.role,
        );
        toast('Profile saved');
      } on AuthException catch (e) {
        toast(e.message);
      } catch (_) {
        toast('Could not save profile');
      }
    }

    Future<void> pickPhoto() async {
      try {
        await uploadAvatar();
      } catch (_) {
        toast('Could not upload photo');
      }
    }

    final initial = (profile.fullName?.trim().isNotEmpty ?? false)
        ? profile.fullName!.trim()[0].toUpperCase()
        : (profile.email.isNotEmpty ? profile.email[0].toUpperCase() : '?');

    return ValueListenableBuilder<bool>(
      valueListenable: profileLoadingNotifier,
      builder: (context, loading, _) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: loading ? null : pickPhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: scheme.primaryContainer,
                          backgroundImage: profile.avatarUrl != null
                              ? NetworkImage(profile.avatarUrl!)
                              : null,
                          child: profile.avatarUrl == null
                              ? Text(
                                  initial,
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: scheme.onPrimaryContainer,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor: scheme.primary,
                            child: Icon(
                              Icons.edit,
                              size: 14,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: profile.isAdmin
                          ? Colors.teal.shade700
                          : scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          profile.isAdmin
                              ? Icons.verified_user_rounded
                              : Icons.person_outline,
                          size: 15,
                          color: profile.isAdmin
                              ? Colors.white
                              : scheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          profile.isAdmin ? 'ADMIN ROLE' : 'USER ROLE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: profile.isAdmin
                                ? Colors.white
                                : scheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Role Switcher Card (Admin vs User)
                  Card(
                    elevation: 0,
                    color: scheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Role & Permissions',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.isAdmin
                                ? 'As an Admin, you can create new Online & Offline events and view full attendee details.'
                                : 'As a User, you can browse events, register to attend, and see who else is attending.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment<String>(
                                  value: 'user',
                                  icon: Icon(Icons.person_outline),
                                  label: Text('User'),
                                ),
                                ButtonSegment<String>(
                                  value: 'admin',
                                  icon: Icon(Icons.admin_panel_settings_outlined),
                                  label: Text('Admin'),
                                ),
                              ],
                              selected: <String>{
                                profile.isAdmin ? 'admin' : 'user',
                              },
                              onSelectionChanged: (selection) {
                                final chosen = selection.first;
                                updateUserRole(chosen);
                                toast(
                                  chosen == 'admin'
                                      ? 'Switched to Admin role (Event creation enabled)'
                                      : 'Switched to User role',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _deco('Display Name', Icons.person_outline),
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Enter your name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: email,
                    enabled: false,
                    decoration: _deco('Email Id', Icons.email_outlined),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: _deco('Phone Number', Icons.phone_outlined),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return null;
                      return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(s)
                          ? null
                          : 'Enter a valid phone number';
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: loading ? null : save,
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Profile'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
