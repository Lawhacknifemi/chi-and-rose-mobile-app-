import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/ui/period_tracker/edit_period_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class FlowTrackerPage extends ConsumerWidget {
  const FlowTrackerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image (Matched with Home Screen)
          Positioned.fill(
            child: Image.asset(
              'assets/home_gradient_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.white),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      children: [
                        // Calendar Strip
                        _buildCalendarStrip(),
                        const SizedBox(height: 24),
                        // Tracker Card
                        _buildTrackerCard(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Period', const Color(0xFFFF005C)), // Pink
              const SizedBox(width: 12),
              _buildLegendItem('Fertile', const Color(0xFF5D5F9E)), // Purple
              const SizedBox(width: 12),
              _buildLegendItem('Luteal', const Color(0xFFF9C9DC)), // Light Pink/Purple
            ],
          ),
          const SizedBox(height: 8),

          // Circular Tracker (Animated)
          const AnimatedCycleTracker(
            currentDay: 21,
            periodLength: 5,
            fertileEnd: 16,
          ),
          // Week Indicator Button
          Transform.translate(
            offset: const Offset(0, -25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8B6CC)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8B6CC).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: const Text('Week 21', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          
          // Timeline Visualization
          Transform.translate(
            offset: const Offset(0, -35),
            child: SizedBox(
               height: 80,
               width: double.infinity,
               child: CustomPaint(
                 painter: TimelinePainter(),
               ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
           text,
           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildCalendarStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '20 January, 2026',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              // Expand Icon
              Icon(Icons.keyboard_arrow_up_rounded, color: Colors.grey.shade600),
            ],
          ),
        ),
        
        // Month Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Week Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _WeekHeader('Sun'),
                  _WeekHeader('Mon'),
                  _WeekHeader('Tue'),
                  _WeekHeader('Wed'),
                  _WeekHeader('Thu'),
                  _WeekHeader('Fri'),
                  _WeekHeader('Sat'),
                ],
              ),
              const SizedBox(height: 12),
              // Days Grid (Jan 2026: 1st is Thursday)
              // Row 1 (Week 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _DayPlaceholder(), _DayPlaceholder(), _DayPlaceholder(), _DayPlaceholder(),
                  _buildCalendarDayNew('1', true), // 1st Selected
                  _buildCalendarDayNew('2', false),
                  _buildCalendarDayNew('3', false),
                ],
              ),
              const SizedBox(height: 12),
              // Row 2 (Week 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCalendarDayNew('4', false), _buildCalendarDayNew('5', false), _buildCalendarDayNew('6', false),
                  _buildCalendarDayNew('7', false), _buildCalendarDayNew('8', false), _buildCalendarDayNew('9', false), _buildCalendarDayNew('10', false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDayNew(String date, bool isSelected, {bool isToday = false}) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E1E1E) : (isToday ? const Color(0xFFE8B6CC).withOpacity(0.5) : Colors.transparent),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            date,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (isSelected)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(1), // Border effect
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.black, size: 16),
            ),
          ),
      ],
    );
  }





  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFC06C84), size: 20),
            ),
          ),
          
          // Title
          const Text(
            'Flow Tracker',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // Actions
          Row(
            children: [


// ... (in _buildHeader)

              // Calendar Button (Floating)
              GestureDetector(
                onTap: () {
                   Navigator.of(context).push(
                     MaterialPageRoute(builder: (context) => const EditPeriodPage()),
                   );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month_outlined, color: Colors.black87, size: 20),
                ),
              ),
               const SizedBox(width: 8),
               // Kebab Menu
               const Icon(Icons.more_vert_rounded, color: Colors.black87, size: 28),
            ],
          ),
        ],
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Curved Line (Split into two colors)
    final pinkPaint = Paint()
      ..color = const Color(0xFFFF005C) // Pink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
      
    final lightPinkPaint = Paint()
      ..color = const Color(0xFFF9C9DC) // Light Pink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Split point calculations (De Casteljau's algorithm for t=0.5)
    // P0=(0,20), P1=(w/2, h+20), P2=(w,20)
    // Q0 = (w/4, 20 + h/2)
    // B  = (w/2, 20 + h/2)
    // Q1 = (3w/4, 20 + h/2)
    
    double midY = 20 + size.height / 2;
    
    // Left Path (Start to Center)
    final path1 = Path();
    path1.moveTo(0, 20);
    path1.quadraticBezierTo(
      size.width * 0.25, midY, 
      size.width * 0.5, midY
    );
    canvas.drawPath(path1, pinkPaint);
    
    // Right Path (Center to End)
    final path2 = Path();
    path2.moveTo(size.width * 0.5, midY); // Start from center
    path2.quadraticBezierTo(
      size.width * 0.75, midY, 
      size.width, 20
    );
    canvas.drawPath(path2, lightPinkPaint);

    // 2. Dots on the line
    final dotPaint = Paint()
      ..style = PaintingStyle.fill;
      
    // _getYOnCurve: y(t) = 20 + 2h(t - t^2) where t = x / width
    double getY(double x) {
      double t = x / size.width;
      return 20 + 2 * size.height * (t - t * t);
    }
      
    // Helper to draw dots along the curve (dynamically calculated positions)
    _drawTimelineDot(canvas, Offset(20, getY(20)), 6, const Color(0xFFFF005C), dotPaint);
    _drawTimelineDot(canvas, Offset(size.width * 0.25, getY(size.width * 0.25)), 8, const Color(0xFFFF005C), dotPaint);
    
    // Central active dot (dashed ring)
    _drawActiveDot(canvas, Offset(size.width * 0.5, getY(size.width * 0.5)), dotPaint);
    
    _drawTimelineDot(canvas, Offset(size.width * 0.75, getY(size.width * 0.75)), 6, const Color(0xFFF8BBD0), dotPaint); // Light pink
    _drawTimelineDot(canvas, Offset(size.width - 20, getY(size.width - 20)), 6, const Color(0xFFF8BBD0), dotPaint);
  }
  
  void _drawTimelineDot(Canvas canvas, Offset center, double radius, Color color, Paint paint) {
    canvas.drawCircle(center, radius, paint..color = color);
  }
  
  void _drawActiveDot(Canvas canvas, Offset center, Paint paint) {
    // Outer dashed/dotted ring
    final ringPaint = Paint()
      ..color = const Color(0xFFFF005C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Dotted effect would need PathDashPathEffect
      
    canvas.drawCircle(center, 18, ringPaint);
    
    // Inner filled dot
    paint.color = const Color(0xFFFF005C);
    canvas.drawCircle(center, 10, paint);
    
    // Icon inside
    // (Optional: draw icon manually or assume it's small enough not to need text)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CycleTrackerPainter extends CustomPainter {
  final int cycleLength;
  final int periodLength;
  final int fertileStart; // e.g. Day 10
  final int fertileEnd;   // e.g. Day 16
  final int currentDay;
  final double animationProgress; // 0.0 to 1.0
  final double pulseProgress; // 0.0 to 1.0 (Oscillating)

  CycleTrackerPainter({
    this.cycleLength = 28,
    this.periodLength = 5,
    this.fertileStart = 10,
    this.fertileEnd = 16,
    this.currentDay = 21,
    this.animationProgress = 1.0, 
    this.pulseProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const double strokeWidth = 24;

    // Helper: Degrees per day
    final double degreesPerDay = 360 / cycleLength;
    
    // We start at -90 degrees (12 o'clock)
    const double startAngleOffset = -1.5708; // -90 degrees in radians

    // 0. Background Track (Removed per request)
    // _drawTrack(canvas, center, radius * 0.9, strokeWidth);

    // 4. Background Track (Optional, for continuity - animated)
    // if (animationProgress > 0) {
    //   _drawTrack(canvas, center, radius * 0.62, strokeWidth);
    // }

    // GAP Config
    // With StrokeCap.round, the "visual" gap needs to be larger than the mathematical gap
    // because the rounded ends extend beyond the sweep.
    final double gapRadians = _degreesToRadians(15); 

    // 1. Period Arc (Pink)
    final periodSweep = _daysToRadians(periodLength.toDouble(), degreesPerDay);
    
    // Animate Sweep: We multiply the sweep by progress.
    // However, for individual segments to "grow" sequentially or together? 
    // Simply scaling all of them by progress is easiest for "Entrance".
    
    _drawArc(canvas, center, radius * 0.74, startAngleOffset, (periodSweep - gapRadians) * animationProgress, const Color(0xFFFF005C), strokeWidth);

    // 2. Fertile/Follicular Window Arc (Purple)
    // Start after Period + Gap
    double segment2StartAngle = startAngleOffset + periodSweep; 
    double segment2Days = (fertileEnd - periodLength).toDouble(); 
    double segment2Sweep = _daysToRadians(segment2Days, degreesPerDay);
    
    _drawArc(canvas, center, radius * 0.74, segment2StartAngle, (segment2Sweep - gapRadians) * animationProgress, const Color(0xFF5D5F9E), strokeWidth);

    // 3. Luteal Phase (Light Pink/Purple)
    // Start after Fertile + Gap
    double segment3StartAngle = segment2StartAngle + segment2Sweep;
    double segment3Days = (cycleLength - fertileEnd).toDouble();
    double segment3Sweep = _daysToRadians(segment3Days, degreesPerDay);
    
    _drawArc(canvas, center, radius * 0.74, segment3StartAngle, (segment3Sweep - gapRadians) * animationProgress, const Color(0xFFF9C9DC), strokeWidth); 

    // 5. Current Day Indicator (Only show if animation is near completion)
    if (animationProgress > 0.8) {
      // Fade in effect simulated by opacity or just draw it
       double currentDayAngle = startAngleOffset + _daysToRadians(currentDay.toDouble(), degreesPerDay);
       _drawCurrentDayIndicator(canvas, center, radius * 0.74, currentDayAngle);
    }
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double start, double sweep, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round // Rounded ends
      ..strokeWidth = width;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      paint,
    );
  }
  
  void _drawTrack(Canvas canvas, Offset center, double radius, double width) {
     final paint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
     canvas.drawCircle(center, radius, paint);
  }

  void _drawCurrentDayIndicator(Canvas canvas, Offset center, double radius, double angle) {
    // Glow effect
    final pos = Offset(
      center.dx + radius * (math.cos(angle)),
      center.dy + radius * (math.sin(angle))
    );
    
    // Pulsing Glow
    // Base radius 12, max radius 18
    double glowRadius = 12 + (8 * pulseProgress);
    double glowOpacity = 0.6 - (0.4 * pulseProgress); // Fades as it expands

    canvas.drawCircle(pos, glowRadius, Paint()..color = const Color(0xFFFF005C).withOpacity(glowOpacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw knob
    canvas.drawCircle(pos, 8, paint); 
    canvas.drawCircle(pos, 8, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2); 
    canvas.drawCircle(pos, 4, Paint()..color = const Color(0xFFFF005C)); 
  }

  double _daysToRadians(double days, double degreesPerDay) {
    return _degreesToRadians(days * degreesPerDay);
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



class AnimatedCycleTracker extends StatefulWidget {
  final int currentDay;
  final int periodLength;
  final int fertileEnd;

  const AnimatedCycleTracker({
    super.key,
    required this.currentDay,
    required this.periodLength,
    required this.fertileEnd,
  });

  @override
  State<AnimatedCycleTracker> createState() => _AnimatedCycleTrackerState();
}

class _AnimatedCycleTrackerState extends State<AnimatedCycleTracker> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _breatheController;
  late AnimationController _pulseController;
  late AnimationController _lottieController; // New: For Lottie Ping-Pong
  late Animation<double> _entranceAnimation;
  late Animation<double> _breatheAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Entrance Animation (Draws the ring)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    // 2. Breathing Animation (Stronger scale pulse)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.05).animate( 
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );

    // 3. Pulse Animation (For the indicator glow)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 4. Lottie Controller (Init only, duration set in onLoaded)
    _lottieController = AnimationController(vsync: this);

    // Start
    _entranceController.forward();
    _breatheController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breatheController.dispose();
    _pulseController.dispose();
    _lottieController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceAnimation, _breatheAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: SizedBox(
            height: 370,
            width: 370,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none, // Allow lottie overflow
              children: [
                // 1. Central Image
                _buildDynamicCenterImage(widget.currentDay, widget.periodLength, widget.fertileEnd),

                // 2. Custom Painter (Animated Sweep)
                CustomPaint(
                  size: const Size(370, 370),
                  painter: CycleTrackerPainter(
                    currentDay: widget.currentDay,
                    periodLength: widget.periodLength,
                    fertileEnd: widget.fertileEnd,
                    animationProgress: _entranceAnimation.value,
                    pulseProgress: _pulseAnimation.value, // Pass pulse
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicCenterImage(int currentDay, int periodLength, int fertileEnd) {
    // Determine Phase & Visuals
    Color overlayColor = Colors.transparent;

    if (currentDay <= periodLength) {
      // Period
      overlayColor = Colors.white.withOpacity(0.4);
    } else if (currentDay > periodLength && currentDay <= fertileEnd) {
      // Fertile
      overlayColor = Colors.blue.shade900.withOpacity(0.3);
    } else {
      // Luteal
      overlayColor = Colors.transparent;
    }

    return Transform.translate(
      offset: const Offset(0, -25), // Shift closer to top to fix "top gap"
      child: Container(
        width: 300,
        height: 300,
        clipBehavior: Clip.antiAlias, // Ensure content respects circle
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Color Layer
            Container(color: const Color(0xFFF9C9DC)), 
            
            // 2. The Image (Lottie Animation)
            ClipOval(
              child: Lottie.asset(
                  'assets/embryoanimation.json', 
                  fit: BoxFit.cover,
                  controller: _lottieController, // Bind controller
                  onLoaded: (composition) {
                    _lottieController
                      ..duration = composition.duration
                      ..repeat(reverse: true); // Ping-Pong for continuous smooth loop
                  },
                  errorBuilder: (context, error, stackTrace) {
                     return Container(
                       color: Colors.black.withOpacity(0.5), 
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.warning_amber_rounded, size: 48, color: Colors.white),
                           const SizedBox(height: 4),
                           Text("COLD RESTART REQUIRED", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                           Text("Asset Missing", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.white70)),
                         ],
                       ),
                     );
                  },
                ),
            ),
            
            // 3. Phase Overlay/Tint
            Container(color: overlayColor),
          ],
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final String day;
  const _WeekHeader(this.day);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          day,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DayPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 40, height: 40);
  }
}
