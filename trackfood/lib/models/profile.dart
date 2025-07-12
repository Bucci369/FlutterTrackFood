class Profile {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String activityLevel;
  final String goal;
  final String? dietType;
  final bool? isGlutenfree;
  final bool? onboardingCompleted;

  Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.goal,
    this.dietType,
    this.isGlutenfree,
    this.onboardingCompleted,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'],
    name: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim().isEmpty 
        ? json['name'] ?? '' 
        : '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
    age: json['age'] ?? 25,
    gender: json['gender'] ?? 'other',
    heightCm: (json['height_cm'] as num?)?.toDouble() ?? 170.0,
    weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 70.0,
    activityLevel: json['activity_level'] ?? 'moderately_active',
    goal: json['goal'] ?? 'maintain_weight',
    dietType: json['diet_type'],
    isGlutenfree: json['is_glutenfree'] as bool?,
    onboardingCompleted: json['onboarding_completed'] as bool?,
  );
}
