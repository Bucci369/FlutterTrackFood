import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/diary/diary_screen.dart';
import 'screens/onboarding/onboarding_flow_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: true,
  );
  runApp(AppProviders(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackFood App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/dashboard': (context) => const DashboardScreen(),
        '/diary': (context) => const DiaryScreen(),
        '/onboarding': (context) => const OnboardingFlowScreen(),
        '/chat': (context) => const ChatScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
