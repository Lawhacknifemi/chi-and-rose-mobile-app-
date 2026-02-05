part of 'package:flutter_app/router/router.dart';

const periodTrackerShellBranch = TypedStatefulShellBranch<PeriodTrackerShellBranch>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<PeriodTrackerPageRoute>(
      path: PeriodTrackerPageRoute.path,
    ),
  ],
);

class PeriodTrackerShellBranch extends StatefulShellBranchData {
  const PeriodTrackerShellBranch();
}

class PeriodTrackerPageRoute extends GoRouteData with _$PeriodTrackerPageRoute {
  const PeriodTrackerPageRoute();

  static const path = '/period-tracker';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FlowTrackerPage();
  }
}
