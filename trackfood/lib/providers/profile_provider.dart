import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

// State class for the profile
class ProfileState {
  final Profile? profile;
  final bool isLoading;
  final String? error;

  ProfileState({this.profile, this.isLoading = false, this.error});

  ProfileState copyWith({Profile? profile, bool? isLoading, String? error}) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier for the profile
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService = ProfileService();

  ProfileNotifier() : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final profile = await _profileService.getCurrentProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateProfile(Profile newProfile) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final updatedProfile = await _profileService.updateProfile(newProfile);
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow; // Rethrow to be caught in the UI
    }
  }

  /// Temporarily updates the profile state with data from the onboarding flow.
  /// This does NOT save to the database. The summary screen handles the final save.
  void setOnboardingProfile(Profile onboardingProfile) {
    state = state.copyWith(profile: onboardingProfile);
  }
}

// Provider for the ProfileNotifier
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier();
});
