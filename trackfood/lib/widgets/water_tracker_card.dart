import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Import Material library for Card
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/providers/water_provider.dart';
import 'package:trackfood/theme/app_colors.dart';
import 'package:trackfood/theme/app_typography.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class WaterTrackerCard extends ConsumerWidget {
  const WaterTrackerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterIntakeAsync = ref.watch(waterIntakeProvider);

    return Card(
      elevation: 0, // Flatter design to match dashboard
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.separator, width: 1), // Add border
      ),
      color: const Color(0xFFF6F1E7), // Match dashboard card color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: waterIntakeAsync.when(
          data: (intake) {
            // Ensure progress is always a double
            final progress =
                (intake.dailyGoalMl > 0
                        ? intake.amountMl / intake.dailyGoalMl
                        : 0.0)
                    .clamp(0.0, 1.0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.drop_fill,
                      color: AppColors.systemBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Wasser-Tracker',
                      style: AppTypography.title3.copyWith(
                        color: AppColors.label,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearPercentIndicator(
                  percent: progress,
                  lineHeight: 8.0,
                  barRadius: const Radius.circular(4),
                  progressColor: AppColors.systemBlue,
                  backgroundColor: AppColors.tertiarySystemFill,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '${intake.amountMl} / ${intake.dailyGoalMl} ml',
                    style: AppTypography.subhead.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAddButton(ref, '+150 ml', 150),
                    _buildAddButton(ref, '+250 ml', 250),
                    _buildAddButton(ref, '+500 ml', 500),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (err, stack) => Center(child: Text('Fehler: $err')),
        ),
      ),
    );
  }

  Widget _buildAddButton(WidgetRef ref, String text, int amount) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.tertiarySystemFill,
      onPressed: () {
        ref.read(waterIntakeProvider.notifier).addWater(amount);
      },
      child: Text(
        text,
        style: AppTypography.body.copyWith(color: AppColors.systemBlue),
      ),
    );
  }
}
