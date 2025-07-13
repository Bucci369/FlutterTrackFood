import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for date formatting
import 'screens/auth/auth_wrapper.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/diary/diary_screen.dart';
import 'screens/onboarding/onboardingFlowScreen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart'; // Import the new splash screen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE', null); // Initialize date formatting
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    // Disable debug output for production
    // debug: kDebugMode,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using CupertinoApp as the root for consistent Cupertino design
    return CupertinoApp(
      title: 'TrackFood',
      theme: const CupertinoThemeData(
        primaryColor: Color(0xFF34A0A4),
        scaffoldBackgroundColor: Color(0xFFF6F1E7), // Apple White
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthWrapper(),
        '/dashboard': (context) => const DashboardScreen(),
        '/diary': (context) => const DiaryScreen(),
        '/onboarding': (context) => const OnboardingFlowScreen(),
        '/chat': (context) => const ChatScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
