part of 'package:flutter_app/router/router.dart';

@TypedGoRoute<OnboardingPageRoute>(
  path: OnboardingPageRoute.path,
)
class OnboardingPageRoute extends GoRouteData with _$OnboardingPageRoute {
  const OnboardingPageRoute();

  static const path = '/onboarding';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OnboardingPage();
  }
}
