import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/chat_page.dart';
import 'pages/rooms_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wkbmchwgzyxqdikxawbw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndrYm1jaHdnenl4cWRpa3hhd2J3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0NTM0OTUsImV4cCI6MjA3MzAyOTQ5NX0.i8dlOBmW6PjctYl-CAWQlIknuhmppqSnfZE60Q6Jv0g',
  );
  runApp(const Saba3App());
}

final supabase = Supabase.instance.client;

class Saba3App extends StatelessWidget {
  const Saba3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Saba3 App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6A1B9A),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.cairoTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A1B9A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
        ),
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: '/rooms',
      builder: (context, state) => const RoomsPage(),
    ),
  ],
  redirect: (context, state) {
    final session = supabase.auth.currentSession;
    final loggedIn = session != null;
    final loggingIn = state.matchedLocation == '/';

    if (!loggedIn && !loggingIn) {
      return '/';
    }
    if (loggedIn && loggingIn) {
      return '/home';
    }
    return null;
  },
);
