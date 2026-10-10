import 'package:event_managment_app/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currentIndex = context.select<NavigationProvider, int>(
      (nav) => nav.currentIndex,
    );

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: scheme.primaryContainer,
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
