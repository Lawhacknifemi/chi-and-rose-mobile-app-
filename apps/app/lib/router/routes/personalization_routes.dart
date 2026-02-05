import 'package:go_router/go_router.dart';
import 'package:flutter_app/presentation/ui/personalization/personalization_page.dart';

class PersonalizationPageRoute {
  static const String path = '/personalization';

  static GoRoute get route => GoRoute(
        path: path,
        builder: (context, state) => const PersonalizationPage(),
      );
}
