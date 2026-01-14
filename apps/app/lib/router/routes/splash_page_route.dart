part of 'package:flutter_app/router/router.dart';

@TypedGoRoute<SplashPageRoute>(
  path: SplashPageRoute.path,
)
class SplashPageRoute extends GoRouteData with _$SplashPageRoute {
  const SplashPageRoute();

  static const path = '/splash';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashPage();
  }
}
