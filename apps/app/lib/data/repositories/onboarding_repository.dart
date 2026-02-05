import 'package:flutter_app/composition_root/data_sources/shared_preference_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing onboarding state
class OnboardingRepository {
  OnboardingRepository(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;
  static const _onboardingKey = 'has_completed_onboarding';

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    return _sharedPreferences.getBool(_onboardingKey) ?? false;
  }

  /// Mark onboarding as complete
  Future<void> markOnboardingComplete() async {
    await _sharedPreferences.setBool(_onboardingKey, true);
  }

  /// Reset onboarding status (useful for testing)
  Future<void> resetOnboarding() async {
    await _sharedPreferences.remove(_onboardingKey);
  }
}

/// Provider for onboarding repository
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(sharedPreferencesProvider));
});
