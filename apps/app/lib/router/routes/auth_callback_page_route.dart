import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/composition_root/repositories/auth_repository.dart';
import 'package:flutter_app/router/routes/personalization_routes.dart';
import 'package:go_router/go_router.dart';

class AuthCallbackPageRoute {
  static const path = '/auth/callback';

  static final route = GoRoute(
    path: path,
    builder: (context, state) {
      final token = state.uri.queryParameters['token'];
      return AuthCallbackPage(token: token);
    },
  );
}

class AuthCallbackPage extends ConsumerStatefulWidget {
  const AuthCallbackPage({super.key, this.token});
  final String? token;

  @override
  ConsumerState<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends ConsumerState<AuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleToken();
  }

  Future<void> _handleToken() async {
    if (widget.token != null) {
      // TODO: Save token
      debugPrint('Auth Callback: Token received: ${widget.token}');
      // Save token
      await ref.read(authRepositoryProvider).saveToken(widget.token!);
      
      // Navigate to personalization screen
      if (mounted) {
        context.go(PersonalizationPageRoute.path); 
      }
    } else {
      debugPrint('Auth Callback: No token found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finalizing authentication...'),
          ],
        ),
      ),
    );
  }
}
