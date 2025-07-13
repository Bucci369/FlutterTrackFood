import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For DateUtils
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trackfood/models/diary_entry.dart';
import 'package:trackfood/models/meal_type.dart';
import 'package:trackfood/providers/diary_provider.dart';
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';
import 'widgets/meal_card.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryProvider);
    final diaryNotifier = ref.read(diaryProvider.notifier);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Tagebuch'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: Implement add new entry functionality
          },
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildDateNavigator(
              context,
              diaryState.selectedDate,
              diaryNotifier,
            ),
            Expanded(
              child: diaryState.isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _buildMealList(diaryState.groupedEntries),
            ),
          ],
        ),
      ),
    );
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
            child: const Icon(CupertinoIcons.chevron_right),
            onPressed: isToday
                ? null // Disable button if it's today
                : () => notifier.changeDate(
                    selectedDate.add(const Duration(days: 1)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealList(Map<String, List<DiaryEntry>> groupedEntries) {
    // Define the order of meals
    final mealOrder = [
      MealType.breakfast.name,
      MealType.lunch.name,
      MealType.dinner.name,
      MealType.snack.name,
    ];

    // Dummy values for now, will be replaced with real data later
    const recommendedCalories = 500;

    return ListView(
      children: mealOrder.map((mealTypeName) {
        final entries = groupedEntries[mealTypeName] ?? [];
        return MealCard(
          mealType: MealType.values.firstWhere((e) => e.name == mealTypeName),
          entries: entries,
          recommendedCalories: recommendedCalories,
          onEntryAdded: () {
            // TODO: Implement refresh logic
          },
        );
      }).toList(),
    );
  }
}
