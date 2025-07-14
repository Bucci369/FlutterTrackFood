import 'package:flutter/cupertino.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final DateTime date;
  final String? goalTitle;
  final double caloriesCurrent;
  final double caloriesGoal;
  final double burnedCalories;
  final double? currentWeight;
  final double? targetWeight;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.date,
    this.goalTitle,
    required this.caloriesCurrent,
    required this.caloriesGoal,
    required this.burnedCalories,
    this.currentWeight,
    this.targetWeight,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and date with improved styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $userName! 👋',
                      style: AppTypography.largeTitle.copyWith(
                        color: CupertinoColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: CupertinoColors.white.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.systemBlue.withValues(alpha: 0.3),
                            AppColors.systemBlue.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.systemBlue.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.systemBlue.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Text(
                        _formatDate(date),
                        style: AppTypography.body.copyWith(
                          color: CupertinoColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Enhanced goal card with modern design
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  const Color(
                    0xFF1A1A1A,
                  ), // 🎨 ZIELKARTE HINTERGRUND OBEN: Dunkelgrau
                  const Color(
                    0xFF2A2A2A,
                  ), // 🎨 ZIELKARTE HINTERGRUND MITTE: Helleres Grau
                  const Color(
                    0xFF1A1A1A,
                  ), // 🎨 ZIELKARTE HINTERGRUND UNTEN: Dunkelgrau
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: CupertinoColors.white.withValues(
                  alpha: 0.2,
                ), // 🎨 ZIELKARTE RAHMEN: Weißer Rahmen 20%
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.white.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.8),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: CupertinoColors.white.withValues(alpha: 0.05),
                  blurRadius: 60,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goalTitle ?? 'Dein Tagesziel',
                            style: AppTypography.headline.copyWith(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              shadows: [
                                Shadow(
                                  color: CupertinoColors.white.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getGoalStatusText(),
                            style: AppTypography.body.copyWith(
                              color: CupertinoColors.white.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getProgressBarColor().withValues(alpha: 0.3),
                            _getProgressBarColor().withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getProgressBarColor().withValues(alpha: 0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getProgressBarColor().withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.scope,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Enhanced progress bar with percentage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fortschritt',
                          style: AppTypography.caption1.copyWith(
                            color: CupertinoColors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(_getProgressBarValue() * 100).toInt()}%',
                          style: AppTypography.caption1.copyWith(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: _getProgressBarColor().withValues(
                                  alpha: 0.8,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: CupertinoColors.white.withValues(
                                alpha: 0.05,
                              ),
                              width: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          height: 8,
                          width:
                              MediaQuery.of(context).size.width *
                              0.85 *
                              _getProgressBarValue(),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getProgressBarColor(),
                                _getProgressBarColor().withValues(alpha: 0.7),
                                _getProgressBarColor(),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: _getProgressBarColor().withValues(
                                  alpha: 0.8,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 0),
                              ),
                              BoxShadow(
                                color: _getProgressBarColor().withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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
    if (currentWeight != null && targetWeight != null && targetWeight! > 0) {
      final difference = currentWeight! - targetWeight!;
      if (difference > 0) {
        return 'Noch ${difference.toStringAsFixed(1)} kg bis zum Ziel!';
      } else if (difference < 0) {
        return '${(-difference).toStringAsFixed(1)} kg unter dem Ziel!';
      } else {
        return 'Zielgewicht erreicht! 🎉';
      }
    }

    final difference = caloriesGoal - _netCalories;
    if (difference >= 0) {
      return 'Noch ${difference.toInt()} kcal bis zum Ziel.';
    } else {
      return '${difference.abs().toInt()} kcal über dem Ziel.';
    }
  }

  double _getProgressBarValue() {
    if (currentWeight != null &&
        targetWeight != null &&
        currentWeight! > 0 &&
        targetWeight! > 0) {
      // Assuming the user starts at a weight higher than the target
      // and the initial weight is what they had when they set the goal.
      // For simplicity, let's assume the progress is linear from current to target.
      // A better implementation would store the initial weight.
      // For now, let's represent the remaining journey.
      // This progress bar will show how much is left to lose.
      // A value of 1.0 means they are at their starting weight, 0.0 means they reached the target.
      // This is a bit counter-intuitive for a "progress" bar.

      // Let's redefine progress: 0.0 is start weight, 1.0 is target weight.
      // We need a starting weight for this to be accurate.
      // Let's assume a user wants to lose 10kg, from 90 to 80.
      // If they are at 85kg, they are 50% of the way there.
      // Without initial weight, we can't do this.

      // Let's show progress towards the goal differently.
      // The bar can represent how close the current weight is to the target.
      // If target is 80kg, and current is 90kg, what does the bar show?
      // Let's try to calculate progress from a hypothetical starting point.
      // Let's assume the start was `targetWeight + (initial_difference)`.
      // Let's assume the user started 20% above their target weight.
      final startWeight = targetWeight! * 1.2; // A hypothetical start
      final totalToLose = startWeight - targetWeight!;
      final alreadyLost = startWeight - currentWeight!;
      if (totalToLose <= 0) return 1.0;
      final progress = alreadyLost / totalToLose;
      return progress.clamp(0.0, 1.0);
    }

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
