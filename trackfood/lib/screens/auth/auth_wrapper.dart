import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'auth_screen.dart';
import '../onboarding/onboarding_flow_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../../widgets/animated_logo.dart';
import '../../services/supabase_service.dart';
import '../../providers/profile_provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isOnboardingCompleted = false;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showSplash = false;
      });
    });
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      if (mounted) {
        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.initialSession) {
          final userId = _supabaseService.currentUserId;
          if (userId != null) {
            final profile = await _supabaseService.getProfile(userId);
            setState(() {
              _isOnboardingCompleted = profile?.onboardingCompleted ?? false;
            });
            // ProfileProvider mit dem Profil synchronisieren
            if (profile != null && mounted) {
              context.read<ProfileProvider>().setProfile(profile);
            } else if (mounted) {
              await context.read<ProfileProvider>().loadProfile();
            }
          } else {
            setState(() {
              _isOnboardingCompleted = false;
            });
          }
        } else if (event == AuthChangeEvent.signedOut) {
          setState(() {
            _isOnboardingCompleted = false;
          });
          // ProfileProvider bei Logout leeren
          if (mounted) {
            context.read<ProfileProvider>().clearProfile();
          }
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('User: ${_supabaseService.currentUser}');
    print('OnboardingCompleted: $_isOnboardingCompleted');
    if (_showSplash) {
      return const Scaffold(
        body: CustomAnimatedLogo(),
      );
    }
    if (_supabaseService.currentUser == null) {
      return const AuthScreen();
    } else if (!_isOnboardingCompleted) {
      return const OnboardingFlowScreen();
    } else {
      return const DashboardScreen();
    }
  }
}
