import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/diary_entry.dart';
import 'package:trackfood/models/profile.dart';
import 'package:trackfood/services/supabase_service.dart';
import 'package:collection/collection.dart';

// State for the diary
class DiaryState {
  final DateTime selectedDate;
  final Map<String, List<DiaryEntry>> groupedEntries;
  final bool isLoading;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  DiaryState({
    required this.selectedDate,
    this.groupedEntries = const {},
    this.isLoading = false,
    this.totalCalories = 0.0,
    this.totalProtein = 0.0,
    this.totalCarbs = 0.0,
    this.totalFat = 0.0,
  });

  DiaryState copyWith({
    DateTime? selectedDate,
    Map<String, List<DiaryEntry>>? groupedEntries,
    bool? isLoading,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
  }) {
    return DiaryState(
      selectedDate: selectedDate ?? this.selectedDate,
      groupedEntries: groupedEntries ?? this.groupedEntries,
      isLoading: isLoading ?? this.isLoading,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
    );
  }
}

// Notifier for the diary
class DiaryNotifier extends StateNotifier<DiaryState> {
  final SupabaseService _supabaseService;

  DiaryNotifier(this._supabaseService)
    : super(DiaryState(selectedDate: DateTime.now())) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    state = state.copyWith(isLoading: true);
    final entries = await _supabaseService.getEntriesForDate(
      state.selectedDate,
    );
    final grouped = groupBy(entries, (DiaryEntry entry) => entry.mealType.name);

    // Calculate totals
    final totalCalories = entries.fold<double>(
      0,
      (sum, item) => sum + item.calories,
    );
    final totalProtein = entries.fold<double>(
      0,
      (sum, item) => sum + item.proteinG,
    );
    final totalCarbs = entries.fold<double>(0, (sum, item) => sum + item.carbG);
    final totalFat = entries.fold<double>(0, (sum, item) => sum + item.fatG);

    state = state.copyWith(
      groupedEntries: grouped,
      isLoading: false,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
    );
  }

  void changeDate(DateTime newDate) {
    // Normalize to midnight to avoid timezone issues
    final date = DateTime(newDate.year, newDate.month, newDate.day);
    state = state.copyWith(selectedDate: date);
    loadEntries();
  }

  Future<void> addDiaryEntry({
    required String mealType,
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double quantity,
    String? productCode,
  }) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) return;

    await _supabaseService.addDiaryEntry(
      userId: userId,
      mealType: mealType,
      foodName: foodName,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      quantity: quantity,
      productCode: productCode,
    );
    await loadEntries(); // Reload to show the new entry
  }

  Future<void> deleteDiaryEntry(String entryId) async {
    await _supabaseService.deleteDiaryEntry(entryId);
    loadEntries(); // Refresh entries after deletion
  }
}

// Provider for the DiaryNotifier
final diaryProvider = StateNotifierProvider<DiaryNotifier, DiaryState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return DiaryNotifier(supabaseService);
});

// Provider for the SupabaseService (if not already defined elsewhere)
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Provider to fetch the user's profile
final profileProvider = FutureProvider<Profile?>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final userId = supabaseService.currentUserId;
  if (userId == null) {
    return null;
  }
  return supabaseService.getProfile(userId);
});
