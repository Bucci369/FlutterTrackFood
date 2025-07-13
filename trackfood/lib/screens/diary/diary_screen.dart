import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for initialization
import 'package:trackfood/models/diary_entry.dart';
import 'package:trackfood/models/meal_type.dart';
import 'package:trackfood/providers/diary_provider.dart';
import 'package:trackfood/providers/profile_provider.dart' as profile_provider;
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';
import 'package:trackfood/screens/diary/add_food_screen.dart';
import 'package:trackfood/utils/nutrition_utils.dart';
import 'package:trackfood/widgets/water_tracker_card.dart';
import 'widgets/meal_card.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryProvider);
    final diaryNotifier = ref.read(diaryProvider.notifier);
    final profileState = ref.watch(profile_provider.profileProvider); // Watch the new provider

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF6F1E7), // Apple White
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFF6F1E7), // Apple White
        middle: const Text('Tagebuch'),
        leading: Navigator.canPop(context)
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(CupertinoIcons.back),
              )
            : null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => AddFoodScreen(
                  // Pass the default meal type based on time of day
                  mealType: _getMealTypeForCurrentTime(),
                ),
              ),
            );
          },
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: FutureBuilder(
        // This FutureBuilder ensures that the locale is initialized before building the UI
        future: initializeDateFormatting('de_DE', null),
        builder: (context, snapshot) {
          // Show a loader while waiting for initialization
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          // Show an error message if initialization fails
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Fehler bei der Initialisierung der Lokalisierung.',
                style: AppTypography.body.copyWith(
                  color: CupertinoColors.systemRed,
                ),
              ),
            );
          }

          // Once initialized, build the main content based on profile state
          if (profileState.isLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (profileState.error != null) {
            return Center(child: Text('Fehler: ${profileState.error}'));
          }
          if (profileState.profile == null) {
            return const Center(child: Text('Kein Profil gefunden.'));
          }

          final profile = profileState.profile!;
          final calorieGoal = calculateDailyCalorieGoal(profile);

          return SafeArea(
            child: Column(
              children: [
                _buildDateNavigator(
                  context,
                  diaryState.selectedDate,
                  diaryNotifier,
                ),
                const WaterTrackerCard(),
                const SizedBox(height: 8),
                Expanded(
                  child: diaryState.isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : _buildMealList(
                          diaryState.groupedEntries,
                          diaryNotifier,
                          context,
                          calorieGoal,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  MealType _getMealTypeForCurrentTime() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return MealType.breakfast;
    } else if (hour >= 11 && hour < 15) {
      return MealType.lunch;
    } else if (hour >= 15 && hour < 22) {
      return MealType.dinner;
    } else {
      return MealType.snack;
    }
  }

  Widget _buildDateNavigator(
    BuildContext context,
    DateTime selectedDate,
    DiaryNotifier notifier,
  ) {
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            child: const Icon(CupertinoIcons.chevron_left),
            onPressed: () => notifier.changeDate(
              selectedDate.subtract(const Duration(days: 1)),
            ),
          ),
          Text(
            DateFormat.yMMMMd('de_DE').format(selectedDate),
            style: AppTypography.headline.copyWith(color: AppColors.label),
          ),
          CupertinoButton(
            onPressed: isToday
                ? null // Disable button if it's today
                : () => notifier.changeDate(
                    selectedDate.add(const Duration(days: 1)),
                  ),
            child: const Icon(CupertinoIcons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildMealList(
    Map<String, List<DiaryEntry>> groupedEntries,
    DiaryNotifier notifier,
    BuildContext context,
    int calorieGoal,
  ) {
    // Define the order of meals
    final mealOrder = [
      MealType.breakfast.name,
      MealType.lunch.name,
      MealType.dinner.name,
      MealType.snack.name,
    ];

    // Meal distribution from web app
    const mealDistribution = {
      MealType.breakfast: 0.25,
      MealType.lunch: 0.35,
      MealType.dinner: 0.30,
      MealType.snack: 0.10,
    };

    return ListView(
      children: mealOrder.map((mealTypeName) {
        final mealType = MealType.values.firstWhere(
          (e) => e.name == mealTypeName,
        );
        final entries = groupedEntries[mealTypeName] ?? [];
        return MealCard(
          mealType: mealType,
          entries: entries,
          recommendedCalories: (calorieGoal * (mealDistribution[mealType] ?? 0))
              .round(),
          onAdd: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => AddFoodScreen(mealType: mealType),
              ),
            );
          },
          onDelete: (entryId) {
            notifier.deleteDiaryEntry(entryId);
          },
        );
      }).toList(),
    );
  }
}
