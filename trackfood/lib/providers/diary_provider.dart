import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/models/diary_entry.dart';
import 'package:trackfood/services/supabase_service.dart';
import 'package:collection/collection.dart';

// State for the diary
class DiaryState {
  final DateTime selectedDate;
  final Map<String, List<DiaryEntry>> groupedEntries;
  final bool isLoading;

  DiaryState({
    required this.selectedDate,
    this.groupedEntries = const {},
    this.isLoading = false,
  });

  DiaryState copyWith({
    DateTime? selectedDate,
    Map<String, List<DiaryEntry>>? groupedEntries,
    bool? isLoading,
  }) {
    return DiaryState(
      selectedDate: selectedDate ?? this.selectedDate,
      groupedEntries: groupedEntries ?? this.groupedEntries,
      isLoading: isLoading ?? this.isLoading,
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
    state = state.copyWith(groupedEntries: grouped, isLoading: false);
  }

  void changeDate(DateTime newDate) {
    state = state.copyWith(selectedDate: newDate);
    loadEntries();
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
