import 'package:flutter/material.dart';

/// Model for onboarding screen content
class OnboardingContent {
  const OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    this.iconBottom,
    this.iconTop,
    this.lottieAsset,
    this.lottieBlobColor,
    this.secondaryLottieBlobColor,
    this.useAdvancedBlending = false,
  });

  final String title;
  final String description;
  final String icon;
  final String? iconBottom;
  final String? iconTop;
  final String? lottieAsset;
  final Color? lottieBlobColor;
  final Color? secondaryLottieBlobColor;
  final bool useAdvancedBlending;
}

/// Onboarding screens data
const onboardingScreens = [
  OnboardingContent(
    title: 'Scan Smart, Live Healthy',
    description:
        'Make informed choices on your product purchases based on carcinogenic and your allergic risks.',
    icon: '🔍',
    iconBottom: 'assets/vector_1.svg',
    lottieAsset: 'assets/animation.json',
    lottieBlobColor: Colors.black,
  ),
  OnboardingContent(
    title: 'Personalized Insights',
    description:
        'Get tailored health recommendations based on your unique profile and preferences.',
    icon: '✨',
    iconBottom: 'assets/vector_1.svg',
    lottieAsset: 'assets/onboarding2.json',
    lottieBlobColor: Color(0xFFD4A574), // Brown/Tan (Right)
    secondaryLottieBlobColor: Color(0xFFA8D5BA), // Mint Green (Left)
    useAdvancedBlending: true,
  ),
  OnboardingContent(
    title: 'Track Your Wellness',
    description:
        'Monitor your journey and discover healthier alternatives for the products you use.',
    icon: '📈',
    iconBottom: null,
    lottieAsset: 'assets/onboarding_screen3.json',
    lottieBlobColor: Color(0xFFEECADB), // Soft Pink
    secondaryLottieBlobColor: Color(0xFFA0C4FF), // Light Blue (Left)
    useAdvancedBlending: true,
  ),
];
