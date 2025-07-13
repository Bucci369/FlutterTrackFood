import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/diary_entry.dart';
import 'package:trackfood/models/fasting_session.dart';
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
