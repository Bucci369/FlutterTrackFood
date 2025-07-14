import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Import Material library for LinearProgressIndicator
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final DateTime date;
  final String? goalTitle;
  final String? goalDescription;
  final double caloriesCurrent;
  final double caloriesGoal;
  final double burnedCalories;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.date,
    this.goalTitle,
    this.goalDescription,
    required this.caloriesCurrent,
    required this.caloriesGoal,
    required this.burnedCalories,
  });

  String _formatDate(DateTime date) {
    final weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    final months = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ];

    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];

    return '$weekday, $day. $month';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $userName! 👋',
                    style: AppTypography.largeTitle.copyWith(
                      color: AppColors.label,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
                    style: AppTypography.body.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
              // Achievement badges can be added here later
            ],
          ),

          const SizedBox(height: 20),

          // Goal card with dynamic progress bar
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goalTitle ?? 'Dein Tagesziel',
                  style: AppTypography.headline.copyWith(
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getGoalStatusText(),
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _getProgressBarValue(),
                    backgroundColor: AppColors.separator,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressBarColor(),
                    ),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for the dynamic goal card
  double get _netCalories => caloriesCurrent - burnedCalories;

  String _getGoalStatusText() {
    final difference = caloriesGoal - _netCalories;
    if (difference >= 0) {
      return 'Noch ${difference.toInt()} kcal bis zum Ziel.';
    } else {
      return '${difference.abs().toInt()} kcal über dem Ziel.';
    }
  }

  double _getProgressBarValue() {
    if (caloriesGoal <= 0) return 0;
    final progress = _netCalories / caloriesGoal;
    return progress.clamp(0.0, 1.0);
  }

  Color _getProgressBarColor() {
    final progress = _getProgressBarValue();
    if (progress < 0.8) {
      return CupertinoColors.activeGreen;
    } else if (progress < 1.0) {
      return CupertinoColors.activeOrange;
    } else {
      return CupertinoColors.systemRed;
    }
  }
}
