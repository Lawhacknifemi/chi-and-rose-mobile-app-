import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/ui/common/app_colors.dart';

class CircularTracker extends StatelessWidget {
  const CircularTracker({
    super.key,
    required this.dayOfCycle,
    this.totalDays = 28,
    required this.isPeriodDay,
  });

  final int dayOfCycle;
  final int totalDays;
  final bool isPeriodDay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: CustomPaint(
        painter: _CyclePainter(
          progress: dayOfCycle / totalDays,
          color: isPeriodDay ? AppColors.rose : Colors.teal.shade200,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPeriodDay ? "Period Day" : "Cycle Day",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              Text(
                "$dayOfCycle",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (!isPeriodDay)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                   decoration: BoxDecoration(
                     color: Colors.teal.shade50,
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     "Fertile Window",
                     style: TextStyle(color: Colors.teal.shade700, fontSize: 12),
                   ),
                 ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CyclePainter extends CustomPainter {
  _CyclePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final strokeWidth = 20.0;

    // Background Circle
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    // Start from top (-pi/2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CyclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
