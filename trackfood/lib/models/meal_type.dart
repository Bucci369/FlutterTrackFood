import 'package:flutter/material.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Frühstück';
      case MealType.lunch:
        return 'Mittagessen';
      case MealType.dinner:
        return 'Abendessen';
      case MealType.snack:
        return 'Snacks';
    }
  }

  String get databaseValue {
    switch (this) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.lunch:
        return 'lunch';
      case MealType.dinner:
        return 'dinner';
      case MealType.snack:
        return 'snack';
    }
  }

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

  List<Color> get gradientColors {
    switch (this) {
      case MealType.breakfast:
        return [const Color(0xFF43CEA2), const Color(0xFF185A9D)];
      case MealType.lunch:
        return [const Color(0xFFFFAF7B), const Color(0xFFD76D77)];
      case MealType.dinner:
        return [const Color(0xFFF7971E), const Color(0xFFFFD200)];
      case MealType.snack:
        return [const Color(0xFF76C893), const Color(0xFF34A0A4)];
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cake;
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