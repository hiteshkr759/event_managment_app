import 'package:flutter/material.dart';
import 'package:event_managment_app/notifiers/event_notifer.dart';

class Navigation extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: eventNotifier,
      builder: (context, index, _) {
        return BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => eventNotifier.value = i,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        );
      },
    );
  }
}
