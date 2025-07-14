import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/water_intake.dart';
import 'package:trackfood/services/supabase_service.dart';

// Using .family to create a provider that accepts a date parameter.
// This allows us to fetch water intake for any given day.
final waterIntakeProvider =
    StateNotifierProvider.family<
      WaterIntakeNotifier,
      AsyncValue<WaterIntake>,
      DateTime
    >((ref, date) {
      final supabaseService = ref.watch(supabaseServiceProvider);
      return WaterIntakeNotifier(supabaseService, date);
    });

class WaterIntakeNotifier extends StateNotifier<AsyncValue<WaterIntake>> {
  final SupabaseService _supabaseService;
  final DateTime _date; // The specific date for this notifier instance

  WaterIntakeNotifier(this._supabaseService, this._date)
    : super(const AsyncValue.loading()) {
    _loadWaterIntakeForDate();
  }

  Future<void> _loadWaterIntakeForDate() async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }
    try {
      // Fetch water intake for the specific date passed to the provider
      final intake = await _supabaseService.getWaterIntakeForDate(
        userId,
        _date,
      );
      if (mounted) {
        state = AsyncValue.data(intake);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
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
        if (mounted) {
          state = AsyncValue.data(result);
        }
      } catch (e) {
        // If error, revert to the old state
        if (mounted) {
          state = currentState;
        }
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
