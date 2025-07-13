import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trackfood/models/diary_entry.dart';
import 'package:trackfood/models/meal_type.dart';
import 'package:trackfood/providers/dashboard_providers.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_typography.dart';

class RecentMeals extends ConsumerWidget {
  const RecentMeals({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentMealsAsync = ref.watch(recentMealsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF6F1E7), // Apple White
        border: Border.all(color: AppColors.separator, width: 1),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Letzte Mahlzeiten',
            style: AppTypography.headline.copyWith(color: AppColors.label),
          ),
          const SizedBox(height: AppTheme.paddingM),
          recentMealsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: CupertinoActivityIndicator(),
              ),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'Fehler beim Laden der Mahlzeiten',
                  style: AppTypography.body.copyWith(
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ),
            ),
            data: (meals) {
              return meals.isEmpty
                  ? _buildEmptyState()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        meals.length > 3 ? 3 : meals.length,
                        (index) {
                          final meal = meals[index];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: _buildMealCard(meal, index),
                            ),
                          );
                        },
                      ).toList(),
                    );
            },
          ),
          const SizedBox(height: AppTheme.paddingL),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: AppColors.primary,
              onPressed: () {
                // Use the root navigator to push the named route from main.dart
                Navigator.of(context, rootNavigator: true).pushNamed('/diary');
              },
              child: Text(
                recentMealsAsync.asData?.value.isEmpty ?? true
                    ? 'Mahlzeit hinzufügen'
                    : 'Tagebuch öffnen',
                style: AppTypography.button.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(DiaryEntry meal, int index) {
    // Simple emoji mapping based on meal type
    String getEmojiForMealType(MealType mealType) {
      switch (mealType) {
        case MealType.breakfast:
          return '🥣';
        case MealType.lunch:
          return '🍗';
        case MealType.dinner:
          return '🥗';
        case MealType.snack:
          return '🥛';
      }
    }

    return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.fill,
                border: Border.all(color: AppColors.separator, width: 1),
              ),
              child: Center(
                child: Text(
                  getEmojiForMealType(meal.mealType),
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meal.foodName,
              style: AppTypography.footnote.copyWith(
                color: AppColors.label,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '${meal.calories.toInt()} kcal',
              style: AppTypography.caption1.copyWith(
                color: AppColors.secondaryLabel,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('HH:mm').format(meal.createdAt),
              style: AppTypography.caption1.copyWith(
                color: AppColors.tertiaryLabel,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.square_stack_3d_down_dottedline,
              color: AppColors.secondaryLabel,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Mahlzeiten erfasst',
              style: AppTypography.body.copyWith(
                color: AppColors.label,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Füge deine erste Mahlzeit hinzu!',
              style: AppTypography.footnote.copyWith(
                color: AppColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
