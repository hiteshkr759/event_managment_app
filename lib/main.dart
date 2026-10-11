import 'package:event_managment_app/providers/auth_provider.dart';
import 'package:event_managment_app/providers/events_provider.dart';
import 'package:event_managment_app/providers/navigation_provider.dart';
import 'package:event_managment_app/providers/profile_provider.dart';
import 'package:event_managment_app/views/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes external services and launches the root Flutter widget tree.
///
/// **Purpose:**
/// Serves as the entry point of the Eventora application.
///
/// **How it works:**
/// 1. Calls [WidgetsFlutterBinding.ensureInitialized] so Flutter's native
///    platform channels are ready before running asynchronous code in [main].
/// 2. Calls [Supabase.initialize] to connect the app to the cloud PostgreSQL
///    database and authentication backend.
/// 3. Calls [runApp] with [MyApp] to inflate the root widget on the screen.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ayzvhfgmxymsdlttcxah.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_0Vot3xYkXkgk-oHEZWQnbg_kI9oMmZr',
  );
  runApp(const MyApp());
}

/// The root widget of the Eventora application.
///
/// **Purpose:**
/// Configures global state management ([MultiProvider]), app-wide Material 3
/// theming, and the initial screen ([AuthGate]).
///
/// **How it works:**
/// Wraps [MaterialApp] inside a [MultiProvider] so that every screen and widget
/// in the app can access shared state ([NavigationProvider], [ProfileProvider],
/// [AuthProvider], and [EventsProvider]) using `context.watch` or `context.read`
/// without passing data manually through constructors.
class MyApp extends StatelessWidget {
  /// Creates the root [MyApp] widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider registers all ChangeNotifier state classes at the very top
    // of the widget tree so any child widget can listen to them.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          // AuthProvider reads ProfileProvider so it can automatically load or
          // clear the user's profile whenever login state changes.
          create: (context) => AuthProvider(context.read<ProfileProvider>()),
        ),
        ChangeNotifierProvider<EventsProvider>(
          create: (_) => EventsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Eventora',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
