import 'package:event_managment_app/views/homeView/home.dart';
import 'package:event_managment_app/views/profileView/profile.dart';
import 'package:event_managment_app/widget/drawer.dart';
import 'package:event_managment_app/widget/nav.dart';
import 'package:flutter/material.dart';
import 'package:event_managment_app/notifiers/event_notifer.dart';

class ViewTree extends StatelessWidget {
  const ViewTree({super.key});

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    Center(child: Text('Events Page')),
    ProfilePage(),
    //Center(child: Text('Profile Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Management'), centerTitle: true),
      drawer: const EventDrawer(),
      bottomNavigationBar: const Navigation(),
      body: ValueListenableBuilder<int>(
        valueListenable: eventNotifier,
        builder: (context, index, _) {
          return _pages[index];
        },
      ),
    );
  }
}
