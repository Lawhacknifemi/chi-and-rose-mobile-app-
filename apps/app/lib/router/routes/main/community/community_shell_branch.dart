part of 'package:flutter_app/router/router.dart';

const communityShellBranch = TypedStatefulShellBranch<CommunityShellBranch>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<CommunityPageRoute>(
      path: CommunityPageRoute.path,
    ),
  ],
);

class CommunityShellBranch extends StatefulShellBranchData {
  const CommunityShellBranch();
}

class CommunityPageRoute extends GoRouteData with _$CommunityPageRoute {
  const CommunityPageRoute();

  static const path = '/community';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CommunityPage();
  }
}
