import 'package:flutter/cupertino.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final DateTime date;
  final String? goalTitle;
  final String? goalDescription;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.date,
    this.goalTitle,
    this.goalDescription,
  });

  String _formatDate(DateTime date) {
    final weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag'
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
      'Dezember'
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

          // Goal card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFF6F1E7), // Apple White
              border: Border.all(
                color: AppColors.separator,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.2),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.flag,
                    color: AppColors.label,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
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
                        goalDescription ?? 'Bleib dran! Du schaffst das 💪',
                        style: AppTypography.body.copyWith(
                          color: AppColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
