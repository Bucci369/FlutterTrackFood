import 'package:trackfood/models/profile.dart';

// Mifflin-St Jeor Equation for BMR calculation
double calculateBMR(Profile profile) {
  if (profile.age == null || profile.weightKg == null || profile.heightCm == null || profile.gender == null) {
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

  final multiplier = activityMultipliers[profile.activityLevel ?? 'sedentary'] ?? 1.2;
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
