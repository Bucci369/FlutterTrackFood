import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../models/diary_entry.dart';
import '../models/weight_history.dart';
import '../providers/profile_provider.dart';

class ReportData {
  final List<double> calorieIntakeData;
  final List<double> calorieBurnedData;
  final List<double> weightData;
  final List<String> dateLabels;
  final double avgCalories;
  final double avgBurned;
  final double avgWater;
  final int totalDays;

  ReportData({
    required this.calorieIntakeData,
    required this.calorieBurnedData,
    required this.weightData,
    required this.dateLabels,
    required this.avgCalories,
    required this.avgBurned,
    required this.avgWater,
    required this.totalDays,
  });
}

final reportDataProvider = FutureProvider.family<ReportData, int>((
  ref,
  days,
) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  final profileState = ref.read(profileProvider);

  if (profileState.profile?.id == null) {
    throw Exception('Profile not available');
  }

  final userId = profileState.profile!.id;
  final endDate = DateTime.now();
  final startDate = endDate.subtract(Duration(days: days - 1));

  try {
    // Get historical diary entries
    final diaryEntries = await supabaseService.getDiaryEntriesForDateRange(
      userId,
      startDate,
      endDate,
    );

    // Get weight history
    final weightHistory = await supabaseService.getWeightHistoryForDateRange(
      userId,
      startDate,
      endDate,
    );

    // Get user activities (burned calories)
    final userActivities = await supabaseService.getUserActivitiesForDateRange(
      userId,
      startDate,
      endDate,
    );

    // Group diary entries by date
    final Map<DateTime, List<DiaryEntry>> entriesByDate = {};
    for (final entry in diaryEntries) {
      final dateKey = DateTime(
        entry.entryDate.year,
        entry.entryDate.month,
        entry.entryDate.day,
      );
      entriesByDate.putIfAbsent(dateKey, () => []).add(entry);
    }

    // Group weight entries by date
    final Map<DateTime, WeightHistory> weightByDate = {};
    for (final weight in weightHistory) {
      final dateKey = DateTime(
        weight.recordedDate.year,
        weight.recordedDate.month,
        weight.recordedDate.day,
      );
      weightByDate[dateKey] = weight;
    }

    // Group activities by date to get real burned calories
    final Map<DateTime, double> burnedCaloriesByDate = {};
    for (final activity in userActivities) {
      final activityDate = DateTime.parse(activity['activity_date']);
      final dateKey = DateTime(
        activityDate.year,
        activityDate.month,
        activityDate.day,
      );
      final calories = (activity['calories'] as num?)?.toDouble() ?? 0.0;
      burnedCaloriesByDate[dateKey] =
          (burnedCaloriesByDate[dateKey] ?? 0.0) + calories;
    }

    // Generate data for each day
    final List<double> calorieIntakeData = [];
    final List<double> calorieBurnedData = [];
    final List<double> weightData = [];
    final List<String> dateLabels = [];

    double totalCalories = 0;
    double totalBurned = 0;
    double totalWater = 0;
    int daysWithData = 0;

    // Get current weight as fallback
    final currentWeight = profileState.profile?.weightKg ?? 70.0;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);

      // Date label (show last 3 chars for day names)
      final dayName = _getDayName(date);
      dateLabels.add(dayName);

      // Get diary data for this date
      final dayEntries = entriesByDate[dateKey] ?? [];
      final dayCalories = dayEntries.fold<double>(
        0,
        (sum, entry) => sum + entry.calories,
      );

      // Get real burned calories from activities
      final dayBurned = burnedCaloriesByDate[dateKey] ?? 0.0;

      // Get weight data for this date with intelligent interpolation
      double dayWeight;
      if (weightByDate.containsKey(dateKey)) {
        // Direct weight measurement for this date
        dayWeight = weightByDate[dateKey]!.weightKg;
      } else {
        // No measurement for this date - use interpolation or last known weight
        dayWeight = _getInterpolatedWeight(
          dateKey,
          weightByDate,
          currentWeight,
        );
      }

      calorieIntakeData.add(dayCalories);
      calorieBurnedData.add(dayBurned);
      weightData.add(dayWeight);

      if (dayCalories > 0) {
        totalCalories += dayCalories;
        totalBurned += dayBurned;
        totalWater += 2000; // Placeholder for water data
        daysWithData++;
      }
    }

    // Calculate averages
    final avgCalories = daysWithData > 0 ? totalCalories / daysWithData : 0.0;
    final avgBurned = daysWithData > 0 ? totalBurned / daysWithData : 0.0;
    final avgWater = daysWithData > 0 ? totalWater / daysWithData : 0.0;

    return ReportData(
      calorieIntakeData: calorieIntakeData,
      calorieBurnedData: calorieBurnedData,
      weightData: weightData,
      dateLabels: dateLabels,
      avgCalories: avgCalories,
      avgBurned: avgBurned,
      avgWater: avgWater / 1000, // Convert to liters
      totalDays: daysWithData,
    );
  } catch (e) {
    // Return empty data on error
    return ReportData(
      calorieIntakeData: List.filled(days, 0.0),
      calorieBurnedData: List.filled(days, 350.0),
      weightData: List.filled(days, profileState.profile?.weightKg ?? 70.0),
      dateLabels: List.generate(
        days,
        (i) => _getDayName(startDate.add(Duration(days: i))),
      ),
      avgCalories: 0.0,
      avgBurned: 350.0,
      avgWater: 2.0,
      totalDays: 0,
    );
  }
});

String _getDayName(DateTime date) {
  const days = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
  return days[date.weekday % 7];
}

double _getInterpolatedWeight(
  DateTime targetDate,
  Map<DateTime, WeightHistory> weightByDate,
  double fallbackWeight,
) {
  if (weightByDate.isEmpty) {
    return fallbackWeight;
  }

  // Find the closest weight measurements before and after the target date
  DateTime? beforeDate;
  DateTime? afterDate;

  for (final date in weightByDate.keys) {
    if (date.isBefore(targetDate) || date.isAtSameMomentAs(targetDate)) {
      if (beforeDate == null || date.isAfter(beforeDate)) {
        beforeDate = date;
      }
    }
    if (date.isAfter(targetDate) || date.isAtSameMomentAs(targetDate)) {
      if (afterDate == null || date.isBefore(afterDate)) {
        afterDate = date;
      }
    }
  }

  // If we have measurements on both sides, interpolate
  if (beforeDate != null && afterDate != null && beforeDate != afterDate) {
    final beforeWeight = weightByDate[beforeDate]!.weightKg;
    final afterWeight = weightByDate[afterDate]!.weightKg;

    final totalDays = afterDate.difference(beforeDate).inDays;
    final daysSinceStart = targetDate.difference(beforeDate).inDays;

    if (totalDays > 0) {
      final ratio = daysSinceStart / totalDays;
      return beforeWeight + (afterWeight - beforeWeight) * ratio;
    }
  }

  // If we only have a before measurement, use it
  if (beforeDate != null) {
    return weightByDate[beforeDate]!.weightKg;
  }

  // If we only have an after measurement, use it
  if (afterDate != null) {
    return weightByDate[afterDate]!.weightKg;
  }

  // Fallback to profile weight
  return fallbackWeight;
}
