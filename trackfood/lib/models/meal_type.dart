import 'package:flutter/cupertino.dart';

enum MealType {
  breakfast(
    displayName: 'Frühstück',
    icon: CupertinoIcons.sunrise_fill,
    gradientColors: [Color(0xFFFFAA7A), Color(0xFFFFD480)],
    imagePath: 'assets/image/Fruestuck.webp',
  ),
  lunch(
    displayName: 'Mittagessen',
    icon: CupertinoIcons.sun_max_fill,
    gradientColors: [Color(0xFF7AD7F0), Color(0xFF8FE388)],
    imagePath: 'assets/image/Mittagessen.webp',
  ),
  dinner(
    displayName: 'Abendessen',
    icon: CupertinoIcons.moon_stars_fill,
    gradientColors: [Color(0xFF6B7AFF), Color(0xFF8F7AFF)],
    imagePath: 'assets/image/Abendessen.webp',
  ),
  snack(
    displayName: 'Snacks',
    icon: CupertinoIcons.flame_fill,
    gradientColors: [Color(0xFFFF7A7A), Color(0xFFFFB27A)],
    imagePath: 'assets/image/Snacks.webp',
  );

  const MealType({
    required this.displayName,
    required this.icon,
    required this.gradientColors,
    required this.imagePath,
  });

  final String displayName;
  final IconData icon;
  final List<Color> gradientColors;
  final String imagePath;

  String get databaseValue => name;

  double get calorieDistribution {
    switch (this) {
      case MealType.breakfast:
        return 0.25; // 25% of daily calories
      case MealType.lunch:
        return 0.35; // 35%
      case MealType.dinner:
        return 0.30; // 30%
      case MealType.snack:
        return 0.10; // 10%
    }
  }

  static MealType fromString(String value) {
    switch (value) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.breakfast;
    }
  }
}
