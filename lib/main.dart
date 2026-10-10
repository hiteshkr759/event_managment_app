import 'package:event_managment_app/providers/auth_provider.dart';
import 'package:event_managment_app/providers/events_provider.dart';
import 'package:event_managment_app/providers/navigation_provider.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:event_managment_app/views/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ayzvhfgmxymsdlttcxah.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_0Vot3xYkXkgk-oHEZWQnbg_kI9oMmZr',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProxyProvider<ProfileProvider, AuthProvider>(
          create: (context) => AuthProvider(
            profileProvider: context.read<ProfileProvider>(),
          ),
          update: (_, profileProvider, previous) =>
              previous ?? AuthProvider(profileProvider: profileProvider),
        ),
        ChangeNotifierProvider<EventsProvider>(
          create: (_) => EventsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Event Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
