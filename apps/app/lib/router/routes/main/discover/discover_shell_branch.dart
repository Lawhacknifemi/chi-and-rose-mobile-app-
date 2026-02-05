
part of 'package:flutter_app/router/router.dart';

@TypedGoRoute<DiscoverPageRoute>(
  path: DiscoverPageRoute.path,
)
class DiscoverPageRoute extends GoRouteData with _$DiscoverPageRoute {
  const DiscoverPageRoute();

  static const path = '/discover';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProviderScope(child: DiscoverPage());
  }
}
