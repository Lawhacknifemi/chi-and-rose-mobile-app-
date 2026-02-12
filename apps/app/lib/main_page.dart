import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:internal_design_ui/i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/presentation/ui/home/widgets/ai_chat_bottom_sheet.dart';

import 'package:flutter/services.dart'; // For HapticFeedback

class MainPage extends ConsumerWidget {
  const MainPage({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          navigationShell,
          // Floating Notched Navigation Bar with Shadow
          Positioned(
            left: 24,
            right: 24,
            bottom: 30,
            child: Material(
              color: Colors.transparent,
              elevation: 12,
              shadowColor: Colors.black.withOpacity(0.25),
              shape: NotchedRoundedShape(radius: 35), // Custom shape for shadow
              child: Container(
                height: 70, // Reduced height
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: NotchedRoundedShape(radius: 35),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: _buildNavItem(context, 0, Icons.home_outlined, 'HOME')),
                      Expanded(child: _buildNavItem(context, 1, 'assets/cycles.svg', 'CYCLE')),
                      
                      // Precise space for the notch
                      const SizedBox(width: 70),
                      
                      Expanded(child: _buildNavItem(context, -1, Icons.smart_toy_outlined, 'AI MENTOR')),
                      Expanded(child: _buildNavItem(context, 3, 'assets/community_icon.svg', 'COMMUNITY')),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Protruding Scan FAB
          Positioned(
            bottom: 62, // Positioned in the notch
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: GestureDetector(
              onTap: () => _onTap(context, 2),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Subtle outer glow
                    BoxShadow(
                      color: const Color(0xFF5D1A32).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/scan_nav_icon.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, dynamic iconOrPath, String label) {
    final isSelected = index >= 0 && navigationShell.currentIndex == index;
    final color = isSelected ? const Color(0xFF333333) : const Color(0xFFB0BEC5);

    return GestureDetector(
      onTap: () => _onTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(iconOrPath, color),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(dynamic iconOrPath, Color color) {
    if (iconOrPath is IconData) {
      return Icon(iconOrPath, color: color, size: 21);
    } else if (iconOrPath is String) {
      if (iconOrPath.endsWith('.svg')) {
        return SvgPicture.asset(
          iconOrPath,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          width: 21,
          height: 21,
        );
      } else {
        return Image.asset(
          iconOrPath,
          color: color,
          width: 21,
          height: 21,
        );
      }
    }
    return const SizedBox();
  }


  void _onTap(BuildContext context, int index) {
    if (index == -1) {
      HapticFeedback.lightImpact();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AiChatBottomSheet(),
      );
      return;
    }

    HapticFeedback.lightImpact();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class NotchedRoundedShape extends ShapeBorder {
  final double radius;
  NotchedRoundedShape({required this.radius});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final r = radius;
    final centerX = rect.center.dx;
    const notchWidth = 85.0;
    const notchCurve = 35.0;

    // Start top-left
    path.moveTo(rect.left + r, rect.top);

    // Top edge with notch
    path.lineTo(centerX - notchWidth / 2, rect.top);
    path.quadraticBezierTo(
      centerX - notchWidth / 3, rect.top,
      centerX - notchWidth / 4, rect.top + notchCurve / 2,
    );
    path.arcToPoint(
      Offset(centerX + notchWidth / 4, rect.top + notchCurve / 2),
      radius: const Radius.circular(notchCurve / 2),
      clockwise: true,
    );
    path.quadraticBezierTo(
      centerX + notchWidth / 3, rect.top,
      centerX + notchWidth / 2, rect.top,
    );

    // Top right
    path.lineTo(rect.right - r, rect.top);
    path.arcToPoint(Offset(rect.right, rect.top + r), radius: Radius.circular(r));

    // Bottom right
    path.lineTo(rect.right, rect.bottom - r);
    path.arcToPoint(Offset(rect.right - r, rect.bottom), radius: Radius.circular(r));

    // Bottom left
    path.lineTo(rect.left + r, rect.bottom);
    path.arcToPoint(Offset(rect.left, rect.bottom - r), radius: Radius.circular(r));

    // Close
    path.lineTo(rect.left, rect.top + r);
    path.arcToPoint(Offset(rect.left + r, rect.top), radius: Radius.circular(r));

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
