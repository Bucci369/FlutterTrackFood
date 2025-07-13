class Profile {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final double? targetWeightKg;
  final String? activityLevel;
  final String? goal;
  final String? dietaryRestrictions;
  final String? healthConditions;
  final DateTime? birthDate;
  final List<String>? goals;
  final bool? onboardingCompleted;
  final int? onboardingStep;
  final String? dietType;
  final String? intolerances;
  final bool? isGlutenfree;
  final bool? showOnboarding;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profile({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.targetWeightKg,
    this.activityLevel,
    this.goal,
    this.dietaryRestrictions,
    this.healthConditions,
    this.birthDate,
    this.goals,
    this.onboardingCompleted,
    this.onboardingStep,
    this.dietType,
    this.intolerances,
    this.isGlutenfree,
    this.showOnboarding,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      age: json['age'],
      gender: json['gender'],
      heightCm: json['height_cm']?.toDouble(),
      weightKg: json['weight_kg']?.toDouble(),
      targetWeightKg: json['target_weight_kg']?.toDouble(),
      activityLevel: json['activity_level'],
      goal: json['goal'],
      dietaryRestrictions: json['dietary_restrictions'],
      healthConditions: json['health_conditions'],
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      goals: json['goals'] != null ? List<String>.from(json['goals']) : null,
      onboardingCompleted: json['onboarding_completed'],
      onboardingStep: json['onboarding_step'],
      dietType: json['diet_type'],
      intolerances: json['intolerances'],
      isGlutenfree: json['is_glutenfree'],
      showOnboarding: json['show_onboarding'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'age': age,
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'target_weight_kg': targetWeightKg,
      'activity_level': activityLevel,
      'goal': goal,
      'dietary_restrictions': dietaryRestrictions,
      'health_conditions': healthConditions,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'goals': goals,
      'onboarding_completed': onboardingCompleted,
      'onboarding_step': onboardingStep,
      'diet_type': dietType,
      'intolerances': intolerances,
      'is_glutenfree': isGlutenfree,
      'show_onboarding': showOnboarding,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    String? activityLevel,
    String? goal,
    String? dietaryRestrictions,
    String? healthConditions,
    DateTime? birthDate,
    List<String>? goals,
    bool? onboardingCompleted,
    int? onboardingStep,
    String? dietType,
    String? intolerances,
    bool? isGlutenfree,
    bool? showOnboarding,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      healthConditions: healthConditions ?? this.healthConditions,
      birthDate: birthDate ?? this.birthDate,
      goals: goals ?? this.goals,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      dietType: dietType ?? this.dietType,
      intolerances: intolerances ?? this.intolerances,
      isGlutenfree: isGlutenfree ?? this.isGlutenfree,
      showOnboarding: showOnboarding ?? this.showOnboarding,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Utility methods
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  
  // Backward compatibility getter
  String get name => fullName.isEmpty ? (email?.split('@').first ?? 'User') : fullName;
  
  bool get isOnboardingComplete => onboardingCompleted == true;
  
  double? get bmi {
    if (heightCm != null && weightKg != null && heightCm! > 0) {
      final heightM = heightCm! / 100;
      return weightKg! / (heightM * heightM);
    }
    return null;
  }

  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return 'Unbekannt';
    if (bmiValue < 18.5) return 'Untergewicht';
    if (bmiValue < 25) return 'Normalgewicht';
    if (bmiValue < 30) return 'Übergewicht';
    return 'Adipositas';
  }

  // Calorie calculation using Harris-Benedict Formula
  double? get bmr {
    if (age == null || weightKg == null || heightCm == null || gender == null) {
      return null;
    }
    
    if (gender!.toLowerCase() == 'male') {
      return 88.362 + (13.397 * weightKg!) + (4.799 * heightCm!) - (5.677 * age!);
    } else {
      return 447.593 + (9.247 * weightKg!) + (3.098 * heightCm!) - (4.330 * age!);
    }
  }

  double? get tdee {
    final baseBmr = bmr;
    if (baseBmr == null) return null;

    final multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    return baseBmr * (multipliers[activityLevel] ?? 1.55);
  }
}
