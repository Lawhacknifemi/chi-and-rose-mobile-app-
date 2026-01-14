import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Snappier reveal
    );

    // Bottom-to-Top Reveal: 0.0 (hidden) to 1.0 (full reveal)
    _revealAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    // Wait for the native "Double Heartbeat Burst" to START its final expansion
    // Caught at 1600ms (the exact moment the big burst begins)
    await Future.delayed(const Duration(milliseconds: 1600));
    
    if (mounted) {
      // Handover immediately to keep the momentum
      FlutterNativeSplash.remove();
      _controller.forward();
    }

    // Wait for the reveal to complete then go home
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E6F4),
      body: Center(
        child: AnimatedBuilder(
          animation: _revealAnimation,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: _revealAnimation.value,
                child: SvgPicture.asset(
                  'assets/frame.svg',
                  width: 250,
                  alignment: Alignment.center,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
