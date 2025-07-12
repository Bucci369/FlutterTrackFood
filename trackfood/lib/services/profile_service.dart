import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user profile
  Future<Profile?> getCurrentProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;
      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Create profile for new user
  Future<Profile> createProfile({
    required String userId,
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final profileData = {
        'id': userId,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'onboarding_completed': false,
        'onboarding_step': 1,
        'show_onboarding': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Retry mechanism for profile creation
      int retryCount = 0;
      while (retryCount < 3) {
        try {
          final response = await _supabase
              .from('profiles')
              .insert(profileData)
              .select()
              .single();

          return Profile.fromJson(response);
        } catch (e) {
          retryCount++;
          if (retryCount >= 3) rethrow;
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }

      throw Exception('Failed to create profile after retries');
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  // Update profile
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final updateData = profile.toJson();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', profile.id)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update specific fields
  Future<Profile> updateProfileFields(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile fields: $e');
    }
  }

  // Complete onboarding
  Future<Profile> completeOnboarding(String userId) async {
    try {
      return await updateProfileFields(userId, {
        'onboarding_completed': true,
        'show_onboarding': false,
        'onboarding_step': null,
      });
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  // Update onboarding step
  Future<Profile> updateOnboardingStep(String userId, int step) async {
    try {
      return await updateProfileFields(userId, {
        'onboarding_step': step,
      });
    } catch (e) {
      throw Exception('Failed to update onboarding step: $e');
    }
  }

  // Update basic info
  Future<Profile> updateBasicInfo({
    required String userId,
    String? firstName,
    String? lastName,
    int? age,
    String? gender,
    DateTime? birthDate,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (age != null) updates['age'] = age;
      if (gender != null) updates['gender'] = gender;
      if (birthDate != null) updates['birth_date'] = birthDate.toIso8601String().split('T')[0];

      return await updateProfileFields(userId, updates);
    } catch (e) {
      throw Exception('Failed to update basic info: $e');
    }
  }

  // Update physical stats
  Future<Profile> updatePhysicalStats({
    required String userId,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (heightCm != null) updates['height_cm'] = heightCm;
      if (weightKg != null) updates['weight_kg'] = weightKg;
      if (targetWeightKg != null) updates['target_weight_kg'] = targetWeightKg;

      return await updateProfileFields(userId, updates);
    } catch (e) {
      throw Exception('Failed to update physical stats: $e');
    }
  }

  // Update goals and preferences
  Future<Profile> updateGoalsAndPreferences({
    required String userId,
    String? goal,
    List<String>? goals,
    String? activityLevel,
    String? dietType,
    String? dietaryRestrictions,
    String? intolerances,
    bool? isGlutenfree,
    String? healthConditions,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (goal != null) updates['goal'] = goal;
      if (goals != null) updates['goals'] = goals;
      if (activityLevel != null) updates['activity_level'] = activityLevel;
      if (dietType != null) updates['diet_type'] = dietType;
      if (dietaryRestrictions != null) updates['dietary_restrictions'] = dietaryRestrictions;
      if (intolerances != null) updates['intolerances'] = intolerances;
      if (isGlutenfree != null) updates['is_glutenfree'] = isGlutenfree;
      if (healthConditions != null) updates['health_conditions'] = healthConditions;

      return await updateProfileFields(userId, updates);
    } catch (e) {
      throw Exception('Failed to update goals and preferences: $e');
    }
  }

  // Calculate daily calorie needs
  double? calculateDailyCalorieNeeds(Profile profile) {
    final bmr = profile.bmr;
    final tdee = profile.tdee;
    
    if (tdee != null) {
      // Adjust for goal
      switch (profile.goal) {
        case 'lose_weight':
          return tdee * 0.8; // 20% deficit
        case 'gain_weight':
        case 'build_muscle':
          return tdee * 1.1; // 10% surplus
        case 'maintain_weight':
        default:
          return tdee;
      }
    }

    return null;
  }

  // Calculate macro targets
  Map<String, double>? calculateMacroTargets(Profile profile) {
    final dailyCalories = calculateDailyCalorieNeeds(profile);
    if (dailyCalories == null) return null;

    // Default macro distribution based on goal
    double proteinPercent = 0.25; // 25%
    double fatPercent = 0.30; // 30%
    double carbPercent = 0.45; // 45%

    // Adjust based on goal
    switch (profile.goal) {
      case 'lose_weight':
        proteinPercent = 0.30; // Higher protein for satiety and muscle preservation
        fatPercent = 0.25;
        carbPercent = 0.45;
        break;
      case 'build_muscle':
        proteinPercent = 0.30; // Higher protein for muscle building
        fatPercent = 0.25;
        carbPercent = 0.45;
        break;
      case 'gain_weight':
        proteinPercent = 0.20;
        fatPercent = 0.35; // Higher fat for calorie density
        carbPercent = 0.45;
        break;
    }

    return {
      'calories': dailyCalories,
      'protein_g': (dailyCalories * proteinPercent) / 4, // 4 cal per gram
      'fat_g': (dailyCalories * fatPercent) / 9, // 9 cal per gram
      'carbs_g': (dailyCalories * carbPercent) / 4, // 4 cal per gram
      'protein_percent': proteinPercent * 100,
      'fat_percent': fatPercent * 100,
      'carbs_percent': carbPercent * 100,
    };
  }

  // Get nutrition recommendations
  Map<String, dynamic> getNutritionRecommendations(Profile profile) {
    final macros = calculateMacroTargets(profile);
    if (macros == null) {
      return {
        'error': 'Insufficient profile data for recommendations',
      };
    }

    final recommendations = <String, dynamic>{
      'daily_calories': macros['calories']?.round(),
      'macros': {
        'protein_g': macros['protein_g']?.round(),
        'carbs_g': macros['carbs_g']?.round(),
        'fat_g': macros['fat_g']?.round(),
      },
      'water_ml': _calculateWaterNeeds(profile),
      'fiber_g': 25 + (profile.gender == 'male' ? 10 : 0), // 25g for women, 35g for men
    };

    // Add specific recommendations based on profile
    final tips = <String>[];
    
    if (profile.goal == 'lose_weight') {
      tips.add('Fokussiere dich auf proteinreiche Lebensmittel für Sättigung');
      tips.add('Erhöhe deine Ballaststoffaufnahme für bessere Sättigung');
    } else if (profile.goal == 'build_muscle') {
      tips.add('Esse alle 3-4 Stunden für optimale Proteinverteilung');
      tips.add('Nimm 20-40g Protein nach dem Training zu dir');
    }

    if (profile.isGlutenfree == true) {
      tips.add('Achte auf versteckte Glutenquellen in verarbeiteten Lebensmitteln');
    }

    if (profile.activityLevel == 'active' || profile.activityLevel == 'very_active') {
      tips.add('Erhöhe deine Kohlenhydrataufnahme an Trainingstagen');
    }

    recommendations['tips'] = tips;
    return recommendations;
  }

  int _calculateWaterNeeds(Profile profile) {
    // Base water needs: 35ml per kg body weight
    final baseWater = (profile.weightKg ?? 70) * 35;
    
    // Adjust for activity level
    final activityMultiplier = {
      'sedentary': 1.0,
      'light': 1.1,
      'moderate': 1.2,
      'active': 1.3,
      'very_active': 1.4,
    };
    
    return (baseWater * (activityMultiplier[profile.activityLevel] ?? 1.0)).round();
  }

  // Delete profile (GDPR compliance)
  Future<void> deleteProfile(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }

  // Check if profile exists
  Future<bool> profileExists(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}