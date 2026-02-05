// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore, deprecated_member_use

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasCompletedOnboardingHash() =>
    r'649fa5bebcd4a414d96a84be3584929fe4f96928';

/// Provider to check if onboarding has been completed
///
/// Copied from [hasCompletedOnboarding].
@ProviderFor(hasCompletedOnboarding)
final hasCompletedOnboardingProvider = AutoDisposeFutureProvider<bool>.internal(
  hasCompletedOnboarding,
  name: r'hasCompletedOnboardingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasCompletedOnboardingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasCompletedOnboardingRef = AutoDisposeFutureProviderRef<bool>;
String _$onboardingNotifierHash() =>
    r'd24b06692ef34777e9f2be507e376dfa414d3f92';

/// Provider to complete onboarding
///
/// Copied from [OnboardingNotifier].
@ProviderFor(OnboardingNotifier)
final onboardingNotifierProvider =
    AutoDisposeAsyncNotifierProvider<OnboardingNotifier, bool>.internal(
      OnboardingNotifier.new,
      name: r'onboardingNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingNotifier = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
