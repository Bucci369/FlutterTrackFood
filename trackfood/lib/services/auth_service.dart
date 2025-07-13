import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService {
  final SupabaseClient client = Supabase.instance.client;

  // Getter for current user
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => client.auth.currentUser?.id;

  /// Handles deep link authentication (password reset, email confirmation)
  Future<AuthResponse?> handleDeepLink(Uri uri) async {
    try {
      // Extract access_token and refresh_token from the URI
      final Map<String, String> params = uri.queryParameters;
      
      if (params.containsKey('access_token') && params.containsKey('refresh_token')) {
        final String accessToken = params['access_token']!;
        final String refreshToken = params['refresh_token']!;
        
        // Set the session with the tokens
        final AuthResponse response = await client.auth.setSession(accessToken);
        
        return response;
      }
      
      return null;
    } catch (e) {
      print('Error handling deep link: $e');
      return null;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Checks if user session is valid
  bool get isAuthenticated => currentUser != null;

  /// Updates user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }

  /// Sends password reset email
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutterquickstart://reset-password/',
      );
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  /// Updates user email
  Future<void> updateEmail(String newEmail) async {
    try {
      await client.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } catch (e) {
      print('Error updating email: $e');
      rethrow;
    }
  }

  /// Resends email confirmation
  Future<void> resendEmailConfirmation(String email) async {
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      print('Error resending email confirmation: $e');
      rethrow;
    }
  }

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

/// Auth state provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges.map((state) => state.session?.user);
});

/// Authentication status provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

/// Deep Link Handler for Password Reset
class DeepLinkHandler {
  static Future<bool> handlePasswordResetLink(BuildContext context, Uri uri) async {
    try {
      final authService = AuthService();
      final AuthResponse? response = await authService.handleDeepLink(uri);
      
      if (response != null && response.user != null) {
        // Navigate to password reset screen
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/reset-password',
            (route) => false,
          );
        }
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error handling password reset link: $e');
      return false;
    }
  }

  /// Extract token type from deep link
  static String? getTokenType(Uri uri) {
    return uri.queryParameters['type'];
  }

  /// Check if link is for password recovery
  static bool isPasswordRecoveryLink(Uri uri) {
    return getTokenType(uri) == 'recovery';
  }

  /// Check if link is for email confirmation
  static bool isEmailConfirmationLink(Uri uri) {
    return getTokenType(uri) == 'signup';
  }
}