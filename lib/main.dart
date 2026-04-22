import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://mbzxpiwspohhfjcsxtob.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ienhwaXdXcG9oaGZqY3N4dG9iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3MjQ4ODgsImV4cCI6MjA3MTMwMDg4OH0.l8nJA8X-Z2MIPbuNoxuSyjKy5o8Vu5_9-QRPgHlqLaU',
  );
  
  runApp(const Saba3App());
}

final supabase = Supabase.instance.client;

class Saba3App extends StatelessWidget {
  const Saba3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'صباعي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF6A1B9A),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/auth',
  redirect: (context, state) {
    final session = supabase.auth.currentSession;
    final isLoggingIn = state.matchedLocation == '/auth';

    if (session == null && !isLoggingIn) return '/auth';
    if (session != null && isLoggingIn) return '/home';
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
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
  ],
);
