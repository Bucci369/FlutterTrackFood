import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/water_intake.dart';
import 'package:trackfood/services/supabase_service.dart';

final waterIntakeProvider =
    StateNotifierProvider<WaterIntakeNotifier, AsyncValue<WaterIntake>>((ref) {
      final supabaseService = ref.watch(supabaseServiceProvider);
      return WaterIntakeNotifier(supabaseService);
    });

class WaterIntakeNotifier extends StateNotifier<AsyncValue<WaterIntake>> {
  final SupabaseService _supabaseService;

  WaterIntakeNotifier(this._supabaseService)
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }
    try {
      final intake = await _supabaseService.getWaterIntakeForDate(
        userId,
        DateTime.now(),
      );
      state = AsyncValue.data(intake);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addWater(int amount) async {
    final currentState = state;
    if (currentState is AsyncData<WaterIntake>) {
      final intakeId = currentState.value.id;
      // Optimistically update the UI
      final updatedIntake = currentState.value.copyWith(
        amountMl: currentState.value.amountMl + amount,
      );
      state = AsyncValue.data(updatedIntake);

      try {
        // Actualize the data from the backend
        final result = await _supabaseService.addWater(intakeId, amount);
        state = AsyncValue.data(result);
      } catch (e) {
        // If error, revert to the old state
        state = currentState;
        // Optionally, re-throw or handle the error
        print('Failed to add water: $e');
      }
    }
  }
}

// Extension to add copyWith to WaterIntake model
extension WaterIntakeCopyWith on WaterIntake {
  WaterIntake copyWith({int? amountMl, int? dailyGoalMl}) {
    return WaterIntake(
      id: id,
      userId: userId,
      date: date,
      amountMl: amountMl ?? this.amountMl,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
