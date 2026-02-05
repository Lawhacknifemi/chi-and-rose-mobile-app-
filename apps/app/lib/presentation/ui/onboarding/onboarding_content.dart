/// Model for onboarding screen content
class OnboardingContent {
  const OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    this.iconBottom,
    this.iconTop,
    this.lottieAsset,
  });

  final String title;
  final String description;
  final String icon;
  final String? iconBottom;
  final String? iconTop;
  final String? lottieAsset;
}

/// Onboarding screens data
const onboardingScreens = [
  OnboardingContent(
    title: 'Scan Smart, Live Healthy',
    description:
        'Make informed choices on your product purchases based on carcinogenic and your allergic risks.',
    icon: '🔍',
    iconBottom: 'assets/vector_1.svg',
    // iconTop removed, replaced by Lottie
    lottieAsset: 'assets/animation.json',
  ),
  OnboardingContent(
    title: 'Personalized Insights',
    description:
        'Get tailored health recommendations based on your unique profile and preferences.',
    icon: '✨',
  ),
  OnboardingContent(
    title: 'Track Your Wellness',
    description:
        'Monitor your journey and discover healthier alternatives for the products you use.',
    icon: '📈',
  ),
];
