import 'package:event_managment_app/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The Material 3 bottom navigation bar for switching between top-level tabs.
///
/// **Purpose:**
/// Displays the **Home**, **Events**, and **Profile** destinations at the
/// bottom of the screen and highlights the currently active tab.
///
/// **How it works:**
/// 1. Listens to [NavigationProvider.currentIndex] via `context.select` so the
///    active pill indicator (`indicatorColor`) and bold label update
///    automatically whenever the tab changes.
/// 2. Calls [NavigationProvider.setTab] via `context.read` when the user taps
///    a destination.
class Navigation extends StatelessWidget {
  /// Creates the bottom [Navigation] bar.
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Listen to the active tab index from NavigationProvider.
    final currentIndex = context.select<NavigationProvider, int>(
      (nav) => nav.currentIndex,
    );

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: scheme.primaryContainer,
        // WidgetStateProperty dynamically styles the label depending on whether
        // the tab is currently selected or unselected.
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: scheme.onSurfaceVariant,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) =>
            context.read<NavigationProvider>().setTab(index),
        backgroundColor: scheme.surface,
        elevation: 3,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: scheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.home_rounded, color: scheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined, color: scheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.event_rounded, color: scheme.primary),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: scheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.person_rounded, color: scheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
