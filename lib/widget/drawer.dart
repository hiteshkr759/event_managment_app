import 'package:event_managment_app/providers/auth_provider.dart';
import 'package:event_managment_app/providers/events_provider.dart';
import 'package:event_managment_app/providers/navigation_provider.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:event_managment_app/widget/eventora_logo.dart';
import 'package:event_managment_app/widget/role_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Side navigation drawer displaying user profile info and quick actions.
///
/// **Purpose:**
/// Provides an alternative navigation menu from the top-left hamburger icon,
/// showing the current user's name, email, [RoleBadge], page links, a manual
/// Supabase refresh button, and Sign Out.
///
/// **How it works:**
/// 1. Watches [ProfileProvider] to display live user metadata in the header.
/// 2. Selects [NavigationProvider.currentIndex] to highlight the active tab.
/// 3. Closes the drawer via `Navigator.of(context).pop()` before switching tabs
///    or signing out.
class EventDrawer extends StatelessWidget {
  /// Creates an [EventDrawer] widget.
  const EventDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profile = context.watch<ProfileProvider>().profile;
    final currentIndex = context.select<NavigationProvider, int>(
      (nav) => nav.currentIndex,
    );

    // Helper function that updates the active tab in NavigationProvider and
    // closes the side drawer overlay.
    void selectTab(int index) {
      context.read<NavigationProvider>().setTab(index);
      Navigator.of(context).pop();
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF00695C), Color(0xFF26A69A)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const EventoraLogo(
                      size: 32,
                      lightText: true,
                    ),
                    const Spacer(),
                    RoleBadge(isAdmin: profile?.isAdmin ?? false),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  profile?.displayName ?? 'Eventora Explorer',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profile?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            selected: currentIndex == 0,
            selectedColor: scheme.primary,
            selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.45),
            leading: Icon(
              currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
            ),
            title: const Text('Home'),
            onTap: () => selectTab(0),
          ),
          ListTile(
            selected: currentIndex == 1,
            selectedColor: scheme.primary,
            selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.45),
            leading: Icon(
              currentIndex == 1 ? Icons.event_rounded : Icons.event_outlined,
            ),
            title: const Text('All Events'),
            onTap: () => selectTab(1),
          ),
          ListTile(
            selected: currentIndex == 2,
            selectedColor: scheme.primary,
            selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.45),
            leading: Icon(
              currentIndex == 2 ? Icons.person_rounded : Icons.person_outline,
            ),
            title: const Text('Profile & Role'),
            onTap: () => selectTab(2),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('Refresh Events from Server'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final eventsProvider = context.read<EventsProvider>();
              Navigator.of(context).pop();
              final (_, message) = await eventsProvider.fetchEventsFromServer();
              messenger.showSnackBar(SnackBar(content: Text(message)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.of(context).pop();
              context.read<AuthProvider>().signOut();
            },
          ),
        ],
      ),
    );
  }
}
