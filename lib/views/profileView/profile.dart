import 'package:event_managment_app/providers/auth_provider.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:event_managment_app/widget/auth_widgets.dart';
import 'package:event_managment_app/widget/role_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// User profile editor and role-switching screen (Tab 3).
///
/// **Purpose:**
/// Allows the signed-in user to view and edit their display name, phone number,
/// and avatar photo, switch between **User** and **Admin** roles, or sign out.
///
/// **How it works:**
/// 1. Watches [ProfileProvider] so the avatar, role badge, and loading spinner
///    react immediately to changes.
/// 2. Binds form fields to persistent [TextEditingController]s stored inside
///    [ProfileProvider] so the screen itself remains a `StatelessWidget`.
class ProfilePage extends StatelessWidget {
  /// Creates the [ProfilePage] widget.
  const ProfilePage({super.key});

  // Validates the form, dismisses the keyboard, and calls
  // ProfileProvider.saveProfile() to persist edits to Supabase.
  Future<void> _saveProfile(BuildContext formContext) async {
    final profileProvider = formContext.read<ProfileProvider>();
    if (!(Form.maybeOf(formContext)?.validate() ?? false)) return;
    FocusScope.of(formContext).unfocus();

    try {
      await profileProvider.saveProfile();
      if (formContext.mounted) {
        ScaffoldMessenger.of(
          formContext,
        ).showSnackBar(const SnackBar(content: Text('Profile saved')));
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
          const SnackBar(content: Text('Could not save profile')),
        );
      }
    }
  }

  // Opens the device image gallery and uploads the chosen photo to Supabase
  // Storage via ProfileProvider.uploadAvatar().
  Future<void> _pickPhoto(BuildContext context) async {
    try {
      await context.read<ProfileProvider>().uploadAvatar();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not upload photo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Builder(
              builder: (formContext) => Column(
                children: [
                  GestureDetector(
                    onTap: profileProvider.isLoading
                        ? null
                        : () => _pickPhoto(context),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: scheme.primaryContainer,
                          backgroundImage: profile.avatarUrl != null
                              ? NetworkImage(profile.avatarUrl!)
                              : null,
                          onBackgroundImageError: profile.avatarUrl != null
                              ? (_, _) {}
                              : null,
                          child: profile.avatarUrl == null
                              ? Text(
                                  profile.initial,
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
                  RoleBadge(isAdmin: profile.isAdmin),
                  const SizedBox(height: 20),
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
                                  icon: Icon(
                                    Icons.admin_panel_settings_outlined,
                                  ),
                                  label: Text('Admin'),
                                ),
                              ],
                              selected: <String>{
                                profile.isAdmin ? 'admin' : 'user',
                              },
                              onSelectionChanged: (selection) {
                                final chosen = selection.first;
                                profileProvider.updateRole(chosen);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: profileProvider.nameController,
                    label: 'Display Name',
                    hint: 'Enter your name',
                    prefixIcon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Enter your name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: profileProvider.emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: profileProvider.phoneController,
                    label: 'Phone Number',
                    hint: '+1 234 567 8900',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return null;
                      return RegExp(r'^\+?[0-9\s\-]{7,15}$').hasMatch(s)
                          ? null
                          : 'Enter a valid phone number';
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: profileProvider.isLoading
                          ? null
                          : () => _saveProfile(formContext),
                      child: profileProvider.isLoading
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
                      onPressed: () => context.read<AuthProvider>().signOut(),
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
