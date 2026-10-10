import 'package:flutter/material.dart';

class EventDrawer extends StatelessWidget {
  const EventDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(leading: Icon(Icons.home), title: Text('Home')),
          ListTile(leading: Icon(Icons.event), title: Text('Events')),
          ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
        ],
      ),
    );
  }
}
