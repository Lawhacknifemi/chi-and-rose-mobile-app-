import 'dart:ui';
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
            left: 20,
            right: 20,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(child: _buildNavItem(context, 0, Icons.home_rounded, 'HOME')),
                        Expanded(child: _buildNavItem(context, 1, 'assets/cycles.svg', 'CYCLE')),
                        
                        // Precise space for the FAB
                        const SizedBox(width: 70),
                        
                        Expanded(child: _buildNavItem(context, -1, Icons.auto_awesome_rounded, 'AI MENTOR')),
                        Expanded(child: _buildNavItem(context, 3, 'assets/community_icon.svg', 'COMMUNITY')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Protruding Scan FAB
          Positioned(
            bottom: 54, // Positioned slightly higher for overlap
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: GestureDetector(
              onTap: () => _onTap(context, 2),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC06C84).withOpacity(0.35),
                      blurRadius: 25,
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
    final activeColor = const Color(0xFFC06C84); // Brand Burgundy
    final inactiveColor = const Color(0xFF9E9E9E);
    final color = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => _onTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) => Container(
                    width: 40 * value,
                    height: 32 * value,
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              _buildIcon(iconOrPath, color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: color,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
