import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackfood/models/profile.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // Getter for current user
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => client.auth.currentUser?.id;

  // Get profile by userId
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(response);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // ...existing code...
}
