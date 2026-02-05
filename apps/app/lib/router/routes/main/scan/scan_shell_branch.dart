part of 'package:flutter_app/router/router.dart';

const scanShellBranch = TypedStatefulShellBranch<ScanShellBranch>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<ScanPageRoute>(
      path: ScanPageRoute.path,
    ),
  ],
);

class ScanShellBranch extends StatefulShellBranchData {
  const ScanShellBranch();
}

class ScanPageRoute extends GoRouteData with _$ScanPageRoute {
  const ScanPageRoute();

  static const path = '/scan';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ScanPage();
  }
}
