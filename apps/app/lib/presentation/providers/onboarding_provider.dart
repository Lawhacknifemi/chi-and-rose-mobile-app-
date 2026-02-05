import 'package:flutter_app/data/repositories/onboarding_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

/// Provider to check if onboarding has been completed
@riverpod
Future<bool> hasCompletedOnboarding(Ref ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.hasCompletedOnboarding();
}

/// Provider to complete onboarding
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  Future<bool> build() async {
    final repository = ref.watch(onboardingRepositoryProvider);
    return repository.hasCompletedOnboarding();
  }

  /// Mark onboarding as complete
  Future<void> complete() async {
    final repository = ref.read(onboardingRepositoryProvider);
    await repository.markOnboardingComplete();
    state = const AsyncValue.data(true);
  }

  /// Reset onboarding (for testing)
  Future<void> reset() async {
    final repository = ref.read(onboardingRepositoryProvider);
    await repository.resetOnboarding();
    state = const AsyncValue.data(false);
  }
}
