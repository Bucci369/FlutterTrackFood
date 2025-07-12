class Profile {
  final String id;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String activityLevel;
  final String goal;
  final bool? onboardingCompleted;

  Profile({
    required this.id,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.goal,
    this.onboardingCompleted,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'],
    age: json['age'],
    gender: json['gender'],
    heightCm: (json['height_cm'] as num).toDouble(),
    weightKg: (json['weight_kg'] as num).toDouble(),
    activityLevel: json['activity_level'],
    goal: json['goal'],
    onboardingCompleted: json['onboarding_completed'] as bool?,
  );
}
