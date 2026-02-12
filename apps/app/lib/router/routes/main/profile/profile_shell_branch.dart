part of 'package:flutter_app/router/router.dart';

class ProfilePageRoute extends GoRouteData with _$ProfilePageRoute {
  const ProfilePageRoute();

  static const path = '/profile';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfilePage();
  }
}
