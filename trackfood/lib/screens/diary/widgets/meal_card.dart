import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';
import '../../../models/diary_entry.dart';
import '../../../models/meal_type.dart';

class MealCard extends StatelessWidget {
  final MealType mealType;
  final List<DiaryEntry> entries;
  final int recommendedCalories;
  final VoidCallback onAdd;
  final Function(String) onDelete;

  const MealCard({
    super.key,
    required this.mealType,
    required this.entries,
    required this.recommendedCalories,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.calories,
    );
    final progress = recommendedCalories > 0
        ? totalCalories / recommendedCalories
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.separator, width: 1),
        color: const Color(0xFFF6F1E7), // Apple White
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(mealType.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType.displayName,
                        style: AppTypography.title3.copyWith(
                          color: AppColors.label,
                          fontWeight: FontWeight.w600,
                          inherit: true,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${totalCalories.toInt()} / $recommendedCalories kcal',
                        style: AppTypography.subhead.copyWith(
                          color: AppColors.secondaryLabel,
                          inherit: true,
                        ),
                      ),
                    ],
                  ),
                ),
                // Add button
                CupertinoButton(
                  onPressed: onAdd,
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.fill,
                    ),
                    child: Icon(
                      CupertinoIcons.add,
                      color: AppColors.label,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: AppColors.fill,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: progress > 1.0
                        ? AppColors.systemOrange
                        : AppColors.primary,
                  ),
                ),
              ),
            ),

            if (entries.isNotEmpty) const SizedBox(height: 16),

            // Food entries
            ...entries.map(
              (entry) => Dismissible(
                key: Key(entry.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  onDelete(entry.id);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    color: AppColors.systemRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
                ),
                child: _buildFoodEntry(entry),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildFoodEntry(DiaryEntry entry) {
    return Container(
      height: 72, // Increased height to fit more info
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // Added vertical padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.background,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.foodName,
                  style: AppTypography.body.copyWith(
                    color: AppColors.label,
                    fontWeight: FontWeight.w600,
                    inherit: true,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4), // Add some space
                Text(
                  // Show macros
                  'P: ${entry.proteinG.toStringAsFixed(1)}g  •  C: ${entry.carbG.toStringAsFixed(1)}g  •  F: ${entry.fatG.toStringAsFixed(1)}g',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                    inherit: true,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // Add space before calories
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.calories.toInt()}',
                style: AppTypography.title3.copyWith(
                  color: AppColors.label,
                  fontWeight: FontWeight.w600,
                  inherit: true,
                ),
              ),
              Text(
                'kcal',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.secondaryLabel,
                  inherit: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
