import 'package:flutter/material.dart';

/// Reusable app background widget with topographic pattern
class AppBackground extends StatelessWidget {
  const AppBackground({
    required this.child,
    this.opacity = 0.15,
    super.key,
  });

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background color
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBFC),
          ),
        ),
        // Topographic pattern overlay
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
