import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Reusable pill badge displaying the user's current role (Admin or User).
class RoleBadge extends StatelessWidget {
  final bool isAdmin;

  const RoleBadge({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.teal.shade700 : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.verified_user_rounded : Icons.person_outline,
            size: 15,
            color: isAdmin ? Colors.white : scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            isAdmin ? 'ADMIN ROLE' : 'USER ROLE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAdmin ? Colors.white : scheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive chip that shows current role mode and lets the user toggle
/// between Admin and User mode with one tap.
class RoleModeToggleChip extends StatelessWidget {
  const RoleModeToggleChip({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profileProvider = context.watch<ProfileProvider>();
    final isAdmin = profileProvider.isAdmin;

    return ActionChip(
      avatar: Icon(
        isAdmin ? Icons.admin_panel_settings : Icons.person_outline,
        size: 16,
        color: isAdmin ? Colors.white : scheme.primary,
      ),
      backgroundColor: isAdmin
          ? Colors.teal.shade700
          : scheme.surfaceContainerHighest,
      label: Text(
        isAdmin ? 'Admin Mode' : 'User Mode',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isAdmin ? Colors.white : scheme.onSurface,
        ),
      ),
      onPressed: () {
        final nextRole = isAdmin ? 'user' : 'admin';
        context.read<ProfileProvider>().updateRole(nextRole);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nextRole == 'admin'
                  ? 'Switched to Admin Mode: "+ Create Event" button unlocked!'
                  : 'Switched to User Mode: Create button hidden.',
            ),
          ),
        );
      },
    );
  }
}

