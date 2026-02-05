part of 'package:flutter_app/router/router.dart';

@TypedStatefulShellRoute<MainPageShellRoute>(
  branches: [
    homeShellBranch,
    periodTrackerShellBranch,
    scanShellBranch,
    communityShellBranch,
    profileShellBranch,
  ],
)
class MainPageShellRoute extends StatefulShellRouteData {
  const MainPageShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainPage(navigationShell: navigationShell);
  }
}
