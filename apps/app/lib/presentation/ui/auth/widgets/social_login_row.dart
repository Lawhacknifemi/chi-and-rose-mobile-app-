import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/composition_root/repositories/auth_repository.dart';

class SocialLoginRow extends ConsumerWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          assetPath: 'assets/facebook_icon.svg',
          onTap: () {
             // TODO: Facebook Auth
             print("UI: Tapped Facebook Sign In (Not Implemented)");
          },
        ),
        const SizedBox(width: 20),
        _SocialButton(
          assetPath: 'assets/google_icon.svg',
          onTap: () async {
            print("UI: Tapped Google Sign In - Login Screen");
            await ref.read(authRepositoryProvider).signInWithGoogle();
          },
        ),
        const SizedBox(width: 20),
        _SocialButton(
          assetPath: 'assets/apple_icon.svg',
          onTap: () async {
            print("UI: Tapped Apple Sign In - Login Screen");
            await ref.read(authRepositoryProvider).signInWithApple();
          },
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const _SocialButton({
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
           boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
