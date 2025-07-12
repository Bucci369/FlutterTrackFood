import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfileProvider extends ChangeNotifier {
  Profile? _profile;

  Profile? get profile => _profile;

  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  void updateField(String key, dynamic value) {
    if (_profile == null) return;
    final map = {
      'id': _profile!.id,
      'name': _profile!.name,
      'age': _profile!.age,
      'gender': _profile!.gender,
      'heightCm': _profile!.heightCm,
      'weightKg': _profile!.weightKg,
      'activityLevel': _profile!.activityLevel,
      'goal': _profile!.goal,
      'dietType': _profile!.dietType,
      'isGlutenfree': _profile!.isGlutenfree,
      'onboardingCompleted': _profile!.onboardingCompleted,
    };
    map[key] = value;
    _profile = Profile(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      heightCm: map['heightCm'] as double,
      weightKg: map['weightKg'] as double,
      activityLevel: map['activityLevel'] as String,
      goal: map['goal'] as String,
      dietType: map['dietType'] as String?,
      isGlutenfree: map['isGlutenfree'] as bool?,
      onboardingCompleted: map['onboardingCompleted'] as bool?,
    );
    notifyListeners();
  }
}
