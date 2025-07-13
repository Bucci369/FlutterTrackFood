import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:trackfood/services/supabase_service.dart';
import 'package:trackfood/providers/profile_provider.dart';

class StepState {
  final int steps;
  final int goal;
  final bool isLoading;
  final String? error;

  StepState({
    this.steps = 0,
    this.goal = 10000, // Default goal
    this.isLoading = false,
    this.error,
  });

  StepState copyWith({int? steps, int? goal, bool? isLoading, String? error}) {
    return StepState(
      steps: steps ?? this.steps,
      goal: goal ?? this.goal,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class StepNotifier extends StateNotifier<StepState> {
  final SupabaseService _supabaseService;
  final String? _userId;
  StreamSubscription<StepCount>? _stepCountSubscription;

  StepNotifier(this._supabaseService, this._userId) : super(StepState()) {
    if (_userId != null) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    await _loadInitialSteps();
    _startListeningToSensor();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadInitialSteps() async {
    final today = DateTime.now();
    final stepsFromDb = await _supabaseService.getStepsForDate(_userId!, today);
    state = state.copyWith(steps: stepsFromDb);
  }

  void _startListeningToSensor() {
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) async {
        // This gives total steps since boot. We need to calculate steps for today.
        // A more robust implementation would store the initial step count at the start of the day.
        // For simplicity, we'll just add the delta. This part can be improved later.

        // Let's assume for now we just want to add the sensor data as a new entry.
        // A proper implementation requires handling daily resets.
        // For this version, we will focus on manual adding and displaying total.
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Fehler beim Schrittzähler-Sensor: $error',
        );
      },
    );
  }

  Future<void> addManualSteps(int steps) async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      await _supabaseService.addSteps(
        userId: _userId,
        steps: steps,
        source: 'manual',
        date: DateTime.now(),
      );
      // Reload steps from DB to get the new total
      await _loadInitialSteps();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    super.dispose();
  }
}

final stepProvider = StateNotifierProvider<StepNotifier, StepState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final userId = ref.watch(profileProvider).profile?.id;
  return StepNotifier(supabaseService, userId);
});
