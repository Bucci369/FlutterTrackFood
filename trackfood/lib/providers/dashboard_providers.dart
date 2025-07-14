import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/diary_entry.dart';
import 'package:trackfood/models/fasting_session.dart';
import 'package:trackfood/providers/profile_provider.dart';
import 'package:trackfood/services/supabase_service.dart';

// Provider for the SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Provider for recent meals
final recentMealsProvider = FutureProvider<List<DiaryEntry>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.getRecentMeals();
});

// Provider for recent activities
final recentActivitiesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = ref.watch(supabaseServiceProvider);
  final profile = ref.watch(profileProvider).profile;

  if (profile?.id == null) return [];

  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  final todayString =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  final yesterdayString =
      '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

  final response = await supabase.client
      .from('user_activities')
      .select(
        'activity_name, emoji, duration_min, calories, activity_date, created_at',
      )
      .eq('user_id', profile!.id)
      .gte('activity_date', yesterdayString)
      .lte('activity_date', todayString)
      .order('created_at', ascending: false)
      .limit(10);

  return response.map<Map<String, dynamic>>((activity) {
    final activityDate = DateTime.parse(activity['activity_date']);
    final isToday =
        activityDate.day == today.day &&
        activityDate.month == today.month &&
        activityDate.year == today.year;

    final createdAt = DateTime.parse(activity['created_at']);
    final timeString = isToday
        ? '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
        : 'Gestern';

    return {
      'emoji': activity['emoji'] ?? '🏃‍♂️',
      'name': activity['activity_name'] ?? 'Aktivität',
      'duration': '${activity['duration_min'] ?? 0} min',
      'calories': activity['calories'] ?? 0,
      'time': timeString,
    };
  }).toList();
});

// Provider for daily burned calories
final dailyBurnedCaloriesProvider = FutureProvider<double>((ref) async {
  final supabase = ref.watch(supabaseServiceProvider);
  final profile = ref.watch(profileProvider).profile;

  if (profile?.id == null) return 0.0;

  final today = DateTime.now();
  final startOfDay = DateTime(
    today.year,
    today.month,
    today.day,
  ).toIso8601String();
  final endOfDay = DateTime(
    today.year,
    today.month,
    today.day,
    23,
    59,
    59,
  ).toIso8601String();

  try {
    final response = await supabase.client
        .from('user_activities')
        .select('calories')
        .eq('user_id', profile!.id)
        .gte('activity_date', startOfDay)
        .lte('activity_date', endOfDay);

    double totalCalories = 0.0;
    for (final activity in response) {
      totalCalories += (activity['calories'] as num?)?.toDouble() ?? 0.0;
    }
    return totalCalories;
  } catch (e) {
    print('Error fetching daily burned calories: $e');
    return 0.0;
  }
});

// State Notifier for Fasting
class FastingState {
  final FastingSession? session;
  final bool isLoading;

  FastingState({this.session, this.isLoading = false});

  // A sentinel value to distinguish between "not provided" and "provided as null".
  static const _sentinel = Object();

  FastingState copyWith({Object? session = _sentinel, bool? isLoading}) {
    return FastingState(
      session: session == _sentinel ? this.session : session as FastingSession?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FastingNotifier extends StateNotifier<FastingState> {
  final SupabaseService _supabaseService;

  FastingNotifier(this._supabaseService) : super(FastingState()) {
    loadLatestFastingSession();
  }

  Future<void> loadLatestFastingSession() async {
    state = state.copyWith(isLoading: true);
    final session = await _supabaseService.getLatestFastingSession();
    state = state.copyWith(session: session, isLoading: false);
  }

  Future<void> startFasting(
    String fastingTypeKey,
    String planName,
    Duration duration,
  ) async {
    state = state.copyWith(isLoading: true);
    final newSession = await _supabaseService.startFasting(
      fastingTypeKey,
      planName,
      duration,
    );
    state = state.copyWith(session: newSession, isLoading: false);
  }

  Future<void> stopFasting() async {
    if (state.session == null) return;
    state = state.copyWith(isLoading: true);
    await _supabaseService.stopFasting(state.session!.id);
    // Now this call will correctly set the session to null.
    state = state.copyWith(session: null, isLoading: false);
  }
}

final fastingProvider = StateNotifierProvider<FastingNotifier, FastingState>((
  ref,
) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return FastingNotifier(supabaseService);
});
