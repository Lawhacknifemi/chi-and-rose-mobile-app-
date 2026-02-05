import 'package:go_router/go_router.dart';
import 'package:flutter_app/presentation/ui/auth/auth_page.dart';
import 'package:flutter_app/presentation/ui/auth/signup_page.dart';
import 'package:flutter_app/presentation/ui/auth/password_page.dart';
import 'package:flutter_app/presentation/ui/auth/otp_page.dart';
import 'package:flutter_app/presentation/ui/auth/user_info_page.dart';

class AuthPageRoute {
  static const String path = '/auth/login';

  static GoRoute get route => GoRoute(
        path: path,
        builder: (context, state) => const AuthPage(),
      );
}

class SignupPageRoute {
  static const String path = '/auth/signup';


  static GoRoute get route => GoRoute(
        path: path,
        builder: (context, state) => const SignupPage(),
      );
}

class PasswordPageRoute {
  static const String path = '/auth/signup/password';


  static GoRoute get route => GoRoute(
        path: path,
        builder: (context, state) => PasswordPage(email: state.extra as String?),
      );
}

class OtpPageRoute {
  static const String path = '/auth/signup/otp';


  static GoRoute get route => GoRoute(
        path: path,
        builder: (context, state) => OtpPage(email: state.extra as String?),
      );
}

class UserInfoPageRoute {
  static const String path = '/auth/signup/user-info';

  static GoRoute get route => GoRoute(
        path: path,
        builder: (context, state) => const UserInfoPage(),
      );
}
