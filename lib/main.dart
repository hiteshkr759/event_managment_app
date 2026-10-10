import 'package:event_managment_app/views/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:event_managment_app/notifiers/auth_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ayzvhfgmxymsdlttcxah.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_0Vot3xYkXkgk-oHEZWQnbg_kI9oMmZr',
  );
  initAuth(); // check saved login before the UI shows
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const AuthGate(),
    );
  }
}
