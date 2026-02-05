import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/presentation/providers/onboarding_provider.dart';
import 'package:flutter_app/presentation/ui/common/app_background.dart';
import 'package:flutter_app/presentation/ui/onboarding/onboarding_content.dart';
import 'package:flutter_app/presentation/ui/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:flutter_app/presentation/ui/onboarding/widgets/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/router/routes/auth_routes.dart';

/// Main onboarding page with swipeable screens
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    // Navigate to Auth first. Onboarding will be marked complete after login/signup.
    if (mounted) {
      context.go(AuthPageRoute.path);
    }
  }

  void _nextPage() {
    if (_currentPage < onboardingScreens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        opacity: 1.0,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Top Logo
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, -20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  height: 40,
                  colorFilter: const ColorFilter.mode(
                    Colors.white, 
                    BlendMode.srcIn,
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: onboardingScreens.length,
                  itemBuilder: (context, index) {
                    return OnboardingScreen(
                      content: onboardingScreens[index],
                      isActive: _currentPage == index,
                    );
                  },
                ),
              ),

              // Bottom Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip Button
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Page Indicator
                    OnboardingPageIndicator(
                      currentPage: _currentPage,
                      pageCount: onboardingScreens.length,
                    ),

                    // Next/Get Started Button
                    TextButton(
                      onPressed: _nextPage,
                      child: Text(
                        'Next',
                        style: const TextStyle(
                          color: Color(0xFFEEA5D9), // Pink color
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
