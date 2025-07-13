import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackfood/models/diary_entry.dart';
import 'package:trackfood/models/water_intake.dart';
import 'package:trackfood/models/fasting_session.dart';
import 'package:trackfood/models/user_activity.dart';

class RealtimeService {
  final SupabaseClient client = Supabase.instance.client;

  // Subscription references for cleanup
  final List<RealtimeChannel> _activeChannels = [];

  // Current user ID
  String? get currentUserId => client.auth.currentUser?.id;

  // === Diary Entries Real-time ===

  /// Subscribe to diary entries changes for current user
  RealtimeChannel subscribeToDiaryEntries({
    required Function(DiaryEntry) onInsert,
    required Function(DiaryEntry) onUpdate,
    required Function(String) onDelete,
    Function(String)? onError,
  }) {
    if (currentUserId == null) {
      onError?.call('User not authenticated');
      throw Exception(
        'User must be authenticated to subscribe to diary entries',
      );
    }

    final channel = client.channel('diary_entries_$currentUserId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'diary_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              final entry = DiaryEntry.fromJson(payload.newRecord);
              onInsert(entry);
            } catch (e) {
              onError?.call('Error parsing inserted diary entry: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'diary_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              final entry = DiaryEntry.fromJson(payload.newRecord);
              onUpdate(entry);
            } catch (e) {
              onError?.call('Error parsing updated diary entry: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'diary_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              final entryId = payload.oldRecord['id'] as String;
              onDelete(entryId);
            } catch (e) {
              onError?.call('Error parsing deleted diary entry: $e');
            }
          },
        )
        .subscribe();

    _activeChannels.add(channel);
    return channel;
  }

  // === Water Intake Real-time ===

  /// Subscribe to water intake changes for current user
  RealtimeChannel subscribeToWaterIntake({
    required Function(WaterIntake) onInsert,
    required Function(WaterIntake) onUpdate,
    Function(String)? onError,
  }) {
    if (currentUserId == null) {
      onError?.call('User not authenticated');
      throw Exception(
        'User must be authenticated to subscribe to water intake',
      );
    }

    final channel = client.channel('water_intake_$currentUserId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'water_intake',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              final waterIntake = WaterIntake.fromJson(payload.newRecord);
              onInsert(waterIntake);
            } catch (e) {
              onError?.call('Error parsing inserted water intake: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'water_intake',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              final waterIntake = WaterIntake.fromJson(payload.newRecord);
              onUpdate(waterIntake);
            } catch (e) {
              onError?.call('Error parsing updated water intake: $e');
            }
          },
        )
        .subscribe();

    _activeChannels.add(channel);
    return channel;
  }

  // === Fasting Sessions Real-time ===

  /// Subscribe to fasting sessions changes for current user
  RealtimeChannel subscribeToFastingSessions({
    required Function(FastingSession) onInsert,
    required Function(FastingSession) onUpdate,
    Function(String)? onError,
  }) {
    if (currentUserId == null) {
      onError?.call('User not authenticated');
      throw Exception(
        'User must be authenticated to subscribe to fasting sessions',
      );
    }

    final channel = client.channel('fasting_sessions_$currentUserId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'fasting_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              final session = FastingSession.fromJson(payload.newRecord);
              onInsert(session);
            } catch (e) {
              onError?.call('Error parsing inserted fasting session: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'fasting_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              final session = FastingSession.fromJson(payload.newRecord);
              onUpdate(session);
            } catch (e) {
              onError?.call('Error parsing updated fasting session: $e');
            }
          },
        )
        .subscribe();

    _activeChannels.add(channel);
    return channel;
  }

  // === User Activities Real-time ===

  /// Subscribe to user activities changes for current user
  RealtimeChannel subscribeToUserActivities({
    required Function(UserActivity) onInsert,
    required Function(UserActivity) onUpdate,
    required Function(String) onDelete,
    Function(String)? onError,
  }) {
    if (currentUserId == null) {
      onError?.call('User not authenticated');
      throw Exception(
        'User must be authenticated to subscribe to user activities',
      );
    }

    final channel = client.channel('user_activities_$currentUserId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'user_activities',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              final activity = UserActivity.fromJson(payload.newRecord);
              onInsert(activity);
            } catch (e) {
              onError?.call('Error parsing inserted user activity: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'user_activities',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              final activity = UserActivity.fromJson(payload.newRecord);
              onUpdate(activity);
            } catch (e) {
              onError?.call('Error parsing updated user activity: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'user_activities',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              final activityId = payload.oldRecord['id'] as String;
              onDelete(activityId);
            } catch (e) {
              onError?.call('Error parsing deleted user activity: $e');
            }
          },
        )
        .subscribe();

    _activeChannels.add(channel);
    return channel;
  }

  // === Profile Changes Real-time ===

  /// Subscribe to profile changes for current user
  RealtimeChannel subscribeToProfile({
    required Function(Map<String, dynamic>) onUpdate,
    Function(String)? onError,
  }) {
    if (currentUserId == null) {
      onError?.call('User not authenticated');
      throw Exception('User must be authenticated to subscribe to profile');
    }

    final channel = client.channel('profile_$currentUserId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: currentUserId!,
          ),
          callback: (payload) {
            try {
              onUpdate(payload.newRecord);
            } catch (e) {
              onError?.call('Error parsing updated profile: $e');
            }
          },
        )
        .subscribe();

    _activeChannels.add(channel);
    return channel;
  }

  // === Community Products Real-time ===

  /// Subscribe to new approved products (community feature)
  RealtimeChannel subscribeToProducts({
    required Function(Map<String, dynamic>) onInsert,
    Function(String)? onError,
  }) {
    final channel = client.channel('products_community');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'products',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'is_verified',
            value: true,
          ),
          callback: (payload) {
            try {
              // Only notify if product was just approved
              final oldVerified = payload.oldRecord['is_verified'] as bool?;
              final newVerified = payload.newRecord['is_verified'] as bool?;

              if (oldVerified == false && newVerified == true) {
                onInsert(payload.newRecord);
              }
            } catch (e) {
              onError?.call('Error parsing new approved product: $e');
            }
          },
        )
        .subscribe();

    _activeChannels.add(channel);
    return channel;
  }

  // === Recipes Real-time ===

  /// Subscribe to recipe changes
  RealtimeChannel subscribeToRecipes({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(String) onDelete,
    Function(String)? onError,
  }) {
    final channel = client.channel('recipes');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'recipes',
          callback: (payload) {
            try {
              onInsert(payload.newRecord);
            } catch (e) {
              onError?.call('Error parsing inserted recipe: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'recipes',
          callback: (payload) {
            try {
              onUpdate(payload.newRecord);
            } catch (e) {
              onError?.call('Error parsing updated recipe: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'recipes',
          callback: (payload) {
            try {
              final recipeId = payload.oldRecord['id'] as String;
              onDelete(recipeId);
            } catch (e) {
              onError?.call('Error parsing deleted recipe: $e');
            }
          },
        )
        .subscribe();

    _activeChannels.add(channel);
    return channel;
  }

  // === Connection Management ===

  /// Unsubscribe from a specific channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    try {
      await channel.unsubscribe();
      _activeChannels.remove(channel);
    } catch (e) {
      print('Error unsubscribing from channel: $e');
    }
  }

  /// Unsubscribe from all active channels
  Future<void> unsubscribeAll() async {
    for (final channel in List.from(_activeChannels)) {
      await unsubscribe(channel);
    }
    _activeChannels.clear();
  }

  /// Get connection status
  String getConnectionStatus(RealtimeChannel channel) {
    return channel.toString();
  }

  /// Check if service has active subscriptions
  bool get hasActiveSubscriptions => _activeChannels.isNotEmpty;

  /// Get number of active subscriptions
  int get activeSubscriptionsCount => _activeChannels.length;

  /// Dispose service and cleanup all subscriptions
  Future<void> dispose() async {
    await unsubscribeAll();
  }
}

/// Provider for RealtimeService
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService();

  // Cleanup when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Connection status provider for monitoring
final realtimeConnectionProvider = StateProvider<Map<String, String>>((ref) {
  return {};
});
