import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:internal_design_ui/i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16), // Increased side margin for smaller look
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06), // Even softer shadow
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Ultra-minimal padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, 'Home'),
              _buildNavItem(context, 1, Icons.water_drop_rounded, 'Period'),
              _buildScanItem(context, 2),
              _buildNavItem(context, 3, Icons.groups_rounded, 'Community'),
              _buildNavItem(context, 4, Icons.person_rounded, 'Me'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, dynamic iconOrPath, String label) {
    final isSelected = navigationShell.currentIndex == index;
    final color = isSelected ? const Color(0xFFC06C84) : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => _onTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: _buildIcon(iconOrPath, color),
          ),
          const SizedBox(height: 2),
          // Active Indicator Dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 3 : 0, // Smaller dot
            height: isSelected ? 3 : 0,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(dynamic iconOrPath, Color color) {
    if (iconOrPath is IconData) {
      return Icon(iconOrPath, color: color, size: 20); // Micro size
    } else if (iconOrPath is String) {
      if (iconOrPath.endsWith('.svg')) {
        return SvgPicture.asset(
          iconOrPath,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          width: 20,
          height: 20,
        );
      } else {
        return Image.asset(
          iconOrPath,
          color: color,
          width: 20,
          height: 20,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image, color: color, size: 20);
          },
        );
      }
    }
    return const SizedBox();
  }

  Widget _buildScanItem(BuildContext context, int index) {
      return GestureDetector(
        onTap: () => _onTap(context, index),
        child: Container(
          width: 40, // Micro FAB
          height: 40,
          margin: const EdgeInsets.only(bottom: 12), // Minimal lift
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8E2463), Color(0xFFC06C84)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2), // Thin border
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8E2463).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
        ),
      );
  }

  void _onTap(BuildContext context, int index) {
    if (navigationShell.currentIndex != index) {
      HapticFeedback.lightImpact(); // Haptic feedback
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }
  }
}
