import 'package:event_managment_app/providers/navigation_provider.dart';
import 'package:event_managment_app/views/eventsView/events_page.dart';
import 'package:event_managment_app/views/homeView/home.dart';
import 'package:event_managment_app/views/profileView/profile.dart';
import 'package:event_managment_app/widget/drawer.dart';
import 'package:event_managment_app/widget/nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewTree extends StatelessWidget {
  const ViewTree({super.key});

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    EventsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.select<NavigationProvider, int>(
      (nav) => nav.currentIndex,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Eventora'), centerTitle: true),
      drawer: const EventDrawer(),
      bottomNavigationBar: const Navigation(),
      body: IndexedStack(index: currentIndex, children: _pages),
    );
  }
}
