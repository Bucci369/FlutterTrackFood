import 'package:trackfood/models/profile.dart';

// Mifflin-St Jeor Equation for BMR calculation
double calculateBMR(Profile profile) {
  if (profile.age == null ||
      profile.weightKg == null ||
      profile.heightCm == null ||
      profile.gender == null) {
    return 0;
  }

  final age = profile.age!;
  final weight = profile.weightKg!;
  final height = profile.heightCm!;
  final gender = profile.gender!;

  double bmr;
  if (gender == 'male') {
    bmr = 10 * weight + 6.25 * height - 5 * age + 5;
  } else {
    bmr = 10 * weight + 6.25 * height - 5 * age - 161;
  }

  return bmr;
}

// Calculate Total Daily Energy Expenditure (TDEE)
double calculateTDEE(Profile profile) {
  final bmr = calculateBMR(profile);
  if (bmr == 0) return 0;

  const activityMultipliers = {
    'sedentary': 1.2,
    'lightly_active': 1.375,
    'moderately_active': 1.55,
    'very_active': 1.725,
    'extra_active': 1.9,
  };

  final multiplier =
      activityMultipliers[profile.activityLevel ?? 'sedentary'] ?? 1.2;
  return bmr * multiplier;
}

// Calculate daily calorie goal based on user's goal
int calculateDailyCalorieGoal(Profile profile) {
  final tdee = calculateTDEE(profile);
  if (tdee == 0) return 2000; // Default fallback

  switch (profile.goal) {
    case 'lose_weight':
      return (tdee - 500).round(); // 500 calorie deficit
    case 'gain_weight':
    case 'build_muscle':
      return (tdee + 300).round(); // 300 calorie surplus
    case 'maintain_weight':
    default:
      return tdee.round();
  }
}

class NutritionGoals {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String goalTitle;
  final String goalDescription;

  NutritionGoals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.goalTitle,
    required this.goalDescription,
  });
}

NutritionGoals calculateNutritionalGoals(Profile profile) {
  final tdee = calculateTDEE(profile);
  if (tdee == 0) {
    return NutritionGoals(
      calories: 2000,
      protein: 100,
      carbs: 250,
      fat: 65,
      goalTitle: 'Standardziel',
      goalDescription: 'Bitte vervollständige dein Profil für genaue Ziele.',
    );
  }

  double targetCalories;
  String goalTitle;
  String goalDescription;

  switch (profile.goal) {
    case 'lose_weight': // Corrected from 'weight_loss'
      targetCalories = tdee - 500;
      goalTitle = 'Abnehmen';
      goalDescription = 'Du isst im Kaloriendefizit, um Gewicht zu verlieren.';
      break;
    case 'gain_weight': // Corrected from 'weight_gain'
      targetCalories = tdee + 500;
      goalTitle = 'Zunehmen';
      goalDescription = 'Du isst im Kalorienüberschuss, um Gewicht aufzubauen.';
      break;
    case 'build_muscle': // Corrected from 'muscle_gain'
      targetCalories = tdee + 300;
      goalTitle = 'Muskelaufbau';
      goalDescription = 'Mehr Kalorien und Protein für den Muskelaufbau.';
      break;
    case 'maintain_weight':
    default:
      targetCalories = tdee;
      goalTitle = 'Gewicht halten';
      goalDescription = 'Du isst entsprechend deinem Tagesbedarf.';
      break;
  }

  // 4. Calculate macronutrient goals
  double proteinGrams;
  double fatGrams;
  double carbGrams;

  if (profile.goal == 'build_muscle') {
    // Corrected from 'muscle_gain'
    proteinGrams = (profile.weightKg ?? 70) * 1.8;
    double remainingCalories = targetCalories - (proteinGrams * 4);
    fatGrams = (remainingCalories * 0.35) / 9;
    carbGrams = (remainingCalories * 0.65) / 4;
  } else {
    proteinGrams = (targetCalories * 0.30) / 4;
    fatGrams = (targetCalories * 0.30) / 9;
    carbGrams = (targetCalories * 0.40) / 4;
  }

  return NutritionGoals(
    calories: targetCalories,
    protein: proteinGrams,
    carbs: carbGrams,
    fat: fatGrams,
    goalTitle: goalTitle,
    goalDescription: goalDescription,
  );
}
