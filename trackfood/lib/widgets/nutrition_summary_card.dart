import 'package:flutter/material.dart';
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class NutritionSummaryCard extends StatelessWidget {
  final double totalCalories;
  final double calorieGoal;
  final double totalCarbs;
  final double totalFat;
  final double totalProtein;
  final double totalSodium;

  const NutritionSummaryCard({
    super.key,
    required this.totalCalories,
    required this.calorieGoal,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalProtein,
    required this.totalSodium,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (calorieGoal > 0 ? totalCalories / calorieGoal : 0)
        .clamp(0.0, 1.0)
        .toDouble();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.secondarySystemBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 9.0,
                percent: percent,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${totalCalories.toInt()}',
                      style: AppTypography.title3.copyWith(
                        color: AppColors.label,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
                progressColor: AppColors.primary,
                backgroundColor: AppColors.tertiarySystemFill,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMacroRow(
                    'Kohlenhydrate',
                    totalCarbs,
                    AppColors.carbsMacro,
                  ),
                  const SizedBox(height: 8),
                  _buildMacroRow('Fett', totalFat, AppColors.fatMacro),
                  const SizedBox(height: 8),
                  _buildMacroRow(
                    'Protein',
                    totalProtein,
                    AppColors.proteinMacro,
                  ),
                  const SizedBox(height: 8),
                  _buildMacroRow('Natrium', totalSodium, AppColors.sodiumMacro),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.body.copyWith(color: AppColors.label)),
        const Spacer(),
        Text(
          '${value.toStringAsFixed(0)}g',
          style: AppTypography.body.copyWith(
            color: AppColors.secondaryLabel,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
