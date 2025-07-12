import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final DateTime date;
  final double calorieProgress;
  final double waterProgress;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.date,
    required this.calorieProgress,
    required this.waterProgress,
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              // Achievement badges
              Row(
                children: [
                  if (calorieProgress >= 1.0)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (waterProgress >= 1.0)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Goal card
          GlassmorphicContainer(
            width: double.infinity,
            height: 100,
            borderRadius: 16,
            blur: 20,
            alignment: Alignment.center,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dein Tagesziel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bleib dran! Du schaffst das 💪',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
