import 'package:event_managment_app/providers/events_provider.dart';
import 'package:event_managment_app/providers/navigation_provider.dart';
import 'package:event_managment_app/views/eventsView/events_page.dart';
import 'package:event_managment_app/views/homeView/home.dart';
import 'package:event_managment_app/views/profileView/profile.dart';
import 'package:event_managment_app/widget/drawer.dart';
import 'package:event_managment_app/widget/eventora_logo.dart';
import 'package:event_managment_app/widget/nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The main authenticated shell of the Eventora application.
///
/// **Purpose:**
/// Hosts the top [AppBar], the slide-out [EventDrawer], the bottom [Navigation]
/// bar, and switches between the three primary screens ([HomePage],
/// [EventsPage], and [ProfilePage]).
///
/// **How it works:**
/// Uses an [IndexedStack] for the `body`. Unlike a normal switch that destroys
/// and recreates pages on every tab tap, [IndexedStack] keeps all three pages
/// alive in memory and simply displays the child at `currentIndex`, preserving
/// scroll positions and text input across tab switches.
class ViewTree extends StatelessWidget {
  /// Creates the main [ViewTree] shell.
  const ViewTree({super.key});

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    EventsPage(),
    ProfilePage(),
  ];

  // Pulls the latest events from Supabase when the user taps the refresh icon
  // in the top AppBar, then displays a SnackBar with the result message.
  Future<void> _refreshFromServer(BuildContext context) async {
    final (_, message) = await context
        .read<EventsProvider>()
        .fetchEventsFromServer();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Watch only the active tab index and loading state to minimize rebuilds.
    final currentIndex = context.select<NavigationProvider, int>(
      (nav) => nav.currentIndex,
    );
    final isLoading = context.select<EventsProvider, bool>(
      (events) => events.isLoading,
    );

    return Scaffold(
      appBar: AppBar(
        title: const EventoraLogo(size: 30),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh Events from Supabase',
            onPressed: isLoading ? null : () => _refreshFromServer(context),
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      drawer: const EventDrawer(),
      bottomNavigationBar: const Navigation(),
      body: IndexedStack(index: currentIndex, children: _pages),
    );
  }
}
