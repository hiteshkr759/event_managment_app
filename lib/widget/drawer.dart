import 'package:event_managment_app/providers/auth_provider.dart';
import 'package:event_managment_app/providers/navigation_provider.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:event_managment_app/widget/role_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventDrawer extends StatelessWidget {
  const EventDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final nav = context.read<NavigationProvider>();

    void selectTab(int index) {
      nav.setTab(index);
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
                RoleBadge(isAdmin: profile?.isAdmin ?? false),
                const SizedBox(height: 10),
                Text(
                  profile?.displayName ?? 'Event Management',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => selectTab(0),
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('All Events'),
            onTap: () => selectTab(1),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile & Role'),
            onTap: () => selectTab(2),
          ),
          const Divider(),
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
