import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';
import '../onboarding/onboardingFlowScreen.dart';
import '../dashboard/dashboard_screen.dart';
import '../../services/supabase_service.dart';
import '../../app_providers.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isOnboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {});
      }
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
            if (mounted) {
              setState(() {
                _isOnboardingCompleted = profile?.onboardingCompleted ?? false;
              });
              // ProfileProvider mit dem Profil synchronisieren
              if (profile != null) {
                ref.read(profileProvider).setProfile(profile);
              } else {
                await ref.read(profileProvider).loadProfile();
              }
            }
          } else {
            if (mounted) {
              setState(() {
                _isOnboardingCompleted = false;
              });
            }
          }
        } else if (event == AuthChangeEvent.signedOut) {
          if (mounted) {
            setState(() {
              _isOnboardingCompleted = false;
            });
            // ProfileProvider bei Logout leeren
            ref.read(profileProvider).clearProfile();
          }
        }
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('User: ${_supabaseService.currentUser}');
    print('OnboardingCompleted: $_isOnboardingCompleted');
    if (_supabaseService.currentUser == null) {
      return const AuthScreen();
    } else if (!_isOnboardingCompleted) {
      return const OnboardingFlowScreen();
    } else {
      return const DashboardScreen();
    }
  }
}
