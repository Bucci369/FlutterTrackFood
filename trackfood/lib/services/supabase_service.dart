import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackfood/models/diary_entry.dart';
import 'package:trackfood/models/fasting_session.dart';
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

  // === Fasting Sessions ===

  /// Fetches the latest active fasting session for the current user.
  Future<FastingSession?> getLatestFastingSession() async {
    if (currentUserId == null) return null;
    try {
      final response = await client
          .from('fasting_sessions')
          .select()
          .eq('user_id', currentUserId!)
          .eq('is_active', true)
          .order('start_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return FastingSession.fromJson(response);
    } catch (e) {
      print('Error fetching latest fasting session: $e');
      return null;
    }
  }

  /// Starts a new fasting session.
  Future<FastingSession?> startFasting(
    String fastingTypeKey,
    String planName,
    Duration duration,
  ) async {
    if (currentUserId == null) return null;
    try {
      final response = await client
          .from('fasting_sessions')
          .insert({
            'user_id': currentUserId!,
            'plan': planName,
            'fasting_type': fastingTypeKey,
            'target_duration_hours': duration.inHours,
            'start_time': DateTime.now()
                .toUtc()
                .toIso8601String(), // Save as UTC
            'is_active': true,
            'status': 'active',
          })
          .select()
          .single();

      return FastingSession.fromJson(response);
    } catch (e) {
      print('Error starting fasting session: $e');
      return null;
    }
  }

  /// Stops (completes) a fasting session.
  Future<void> stopFasting(String sessionId) async {
    try {
      await client
          .from('fasting_sessions')
          .update({
            'end_time': DateTime.now().toIso8601String(),
            'is_active': false,
            'status': 'completed',
          })
          .eq('id', sessionId);
    } catch (e) {
      print('Error stopping fasting session: $e');
    }
  }

  // === Diary Entries (Meals) ===

  /// Fetches the most recent meals for the current user for today.
  Future<List<DiaryEntry>> getRecentMeals({int limit = 3}) async {
    if (currentUserId == null) return [];
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(
        today.year,
        today.month,
        today.day,
      ).toIso8601String();

      final response = await client
          .from('diary_entries')
          .select()
          .eq('user_id', currentUserId!)
          .gte('entry_date', startOfDay)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => DiaryEntry.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching recent meals: $e');
      return [];
    }
  }

  /// Fetches all diary entries for the current user for a specific date.
  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) async {
    if (currentUserId == null) return [];
    try {
      final startOfDay = DateTime(
        date.year,
        date.month,
        date.day,
      ).toIso8601String();
      final endOfDay = DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
        59,
      ).toIso8601String();

      final response = await client
          .from('diary_entries')
          .select()
          .eq('user_id', currentUserId!)
          .gte('entry_date', startOfDay)
          .lte('entry_date', endOfDay)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => DiaryEntry.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching entries for date: $e');
      return [];
    }
  }
}
