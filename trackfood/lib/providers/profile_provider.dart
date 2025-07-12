import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load current user profile
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _profile = await _profileService.getCurrentProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create profile for new user
  Future<void> createProfile({
    String? firstName,
    String? lastName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      _profile = await _profileService.createProfile(
        userId: user.id,
        email: user.email,
        firstName: firstName,
        lastName: lastName,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update basic info
  Future<void> updateBasicInfo({
    String? firstName,
    String? lastName,
    int? age,
    String? gender,
    DateTime? birthDate,
  }) async {
    try {
      if (_profile == null) throw Exception('No profile loaded');

      _isLoading = true;
      notifyListeners();

      _profile = await _profileService.updateBasicInfo(
        userId: _profile!.id,
        firstName: firstName,
        lastName: lastName,
        age: age,
        gender: gender,
        birthDate: birthDate,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update physical stats
  Future<void> updatePhysicalStats({
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
  }) async {
    try {
      if (_profile == null) throw Exception('No profile loaded');

      _isLoading = true;
      notifyListeners();

      _profile = await _profileService.updatePhysicalStats(
        userId: _profile!.id,
        heightCm: heightCm,
        weightKg: weightKg,
        targetWeightKg: targetWeightKg,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update goals and preferences
  Future<void> updateGoalsAndPreferences({
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
      if (_profile == null) throw Exception('No profile loaded');

      _isLoading = true;
      notifyListeners();

      _profile = await _profileService.updateGoalsAndPreferences(
        userId: _profile!.id,
        goal: goal,
        goals: goals,
        activityLevel: activityLevel,
        dietType: dietType,
        dietaryRestrictions: dietaryRestrictions,
        intolerances: intolerances,
        isGlutenfree: isGlutenfree,
        healthConditions: healthConditions,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    try {
      if (_profile == null) throw Exception('No profile loaded');

      _isLoading = true;
      notifyListeners();

      _profile = await _profileService.completeOnboarding(_profile!.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update onboarding step
  Future<void> updateOnboardingStep(int step) async {
    try {
      if (_profile == null) throw Exception('No profile loaded');

      _profile = await _profileService.updateOnboardingStep(_profile!.id, step);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Set profile directly (for initial load)
  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  // Clear profile (for logout)
  void clearProfile() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get nutrition recommendations
  Map<String, dynamic>? getNutritionRecommendations() {
    if (_profile == null) return null;
    return _profileService.getNutritionRecommendations(_profile!);
  }
}
