import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/ui/period_tracker/edit_period_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import 'package:flutter_app/presentation/providers/flow_provider.dart';
import 'package:intl/intl.dart';

class FlowTrackerPage extends ConsumerWidget {
  const FlowTrackerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(flowSettingsProvider);
    final now = DateTime.now();
    final calendarAsync = ref.watch(calendarDataProvider(month: now.month, year: now.year));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (settings) {
          final int cycleLength = settings?['averageCycleLength'] ?? 28;
          final int periodLength = settings?['averagePeriodLength'] ?? 5;
          final lastPeriodStart = settings?['lastPeriodStart'] != null 
              ? DateTime.parse(settings!['lastPeriodStart'].toString())
              : null;
          
          int currentDay = 1;
          if (lastPeriodStart != null) {
            currentDay = DateTime.now().difference(lastPeriodStart).inDays + 1;
            // Removed auto-reset logic. If day > cycleLength, it means "Late".
          }

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/home_gradient_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.white),
                ),
              ),
              Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: _buildHeader(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          calendarAsync.when(
                            loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                            error: (err, _) => Text('Calendar Error: $err'),
                            data: (calendarData) => _buildCalendarStrip(calendarData),
                          ),
                          const SizedBox(height: 24),
                          _buildTrackerCard(context, currentDay, cycleLength, periodLength),
                          const SizedBox(height: 24),
                          // Add bottom padding for edge-to-edge
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrackerCard(BuildContext context, int currentDay, int cycleLength, int periodLength) {
    // Medically accurate calculation
    // Ovulation is typically 14 days before the next period
    final ovulationDay = cycleLength - 14;
    // Fertile window is generally 5 days before ovulation + ovulation day + 1 day after
    final fertileStart = ovulationDay - 5;
    final fertileEnd = ovulationDay + 1;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Period', const Color(0xFFFF005C)), 
              const SizedBox(width: 8),
              _buildLegendItem('Follicular', const Color(0xFFE0E0E0)), 
              const SizedBox(width: 8),
              _buildLegendItem('Fertile', const Color(0xFF5D5F9E)), 
              const SizedBox(width: 8),
              _buildLegendItem('Luteal', const Color(0xFFF9C9DC)), 
            ],
          ),
          const SizedBox(height: 8),

          AnimatedCycleTracker(
            currentDay: currentDay,
            periodLength: periodLength,
            fertileStart: fertileStart,
            fertileEnd: fertileEnd,
          ),
          Transform.translate(
            offset: const Offset(0, -25),
            child: _buildCycleStatus(
              currentDay, 
              periodLength, 
              fertileStart, 
              fertileEnd, 
              cycleLength
            ),
          ),
          
          Transform.translate(
            offset: const Offset(0, -35),
            child: SizedBox(
               height: 80,
               width: double.infinity,
               child: CustomPaint(
                 painter: TimelinePainter(
                   cycleLength: cycleLength,
                   periodLength: periodLength,
                   fertileStart: fertileStart,
                   fertileEnd: fertileEnd,
                   currentDay: currentDay,
                 ),
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

  Widget _buildCalendarStrip(Map<String, dynamic> calendarData) {
    // 1. Get raw days
    final List<dynamic> allDays = calendarData['days'] as List<dynamic>? ?? [];
    if (allDays.isEmpty) return const SizedBox.shrink();

    // 2. Filter Logic: Find Period Days
    List<int> periodIndices = [];
    for (int i = 0; i < allDays.length; i++) {
        if (allDays[i]['isPeriod'] == true) {
            periodIndices.add(i);
        }
    }

    int start = 0;
    int end = allDays.length - 1;

    // 3. Determine Range (Buffer +/- 4 days)
    if (periodIndices.isNotEmpty) {
        start = (periodIndices.first - 4).clamp(0, allDays.length - 1);
        end = (periodIndices.last + 4).clamp(0, allDays.length - 1);
    } else {
        // Fallback: Center around Today
        final now = DateTime.now();
        int todayIndex = -1;
        for(int i=0; i<allDays.length; i++) {
            if (DateUtils.isSameDay(DateTime.parse(allDays[i]['date']), now)) {
                todayIndex = i;
                break;
            }
        }
        
        if (todayIndex != -1) {
             start = (todayIndex - 4).clamp(0, allDays.length - 1);
             end = (todayIndex + 4).clamp(0, allDays.length - 1);
        } else {
            // Default to start of month if today not found (unlikely unless next/prev month logic exists)
            start = 0;
            end = math.min(8, allDays.length - 1);
        }
    }

    final daysToShow = allDays.sublist(start, end + 1);

    // 4. Render Horizontal List
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        
        SizedBox(
            height: 80, // Height for Day Name + Date Bubble
            child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: daysToShow.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                    final dayData = daysToShow[index];
                    final date = DateTime.parse(dayData['date'].toString());
                    final isSelected = dayData['isPeriod'] == true;
                    final isToday = DateUtils.isSameDay(date, DateTime.now());
                    
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text(
                                DateFormat('E').format(date), // Mon, Tue
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500
                                ),
                            ),
                            const SizedBox(height: 8),
                            _buildCalendarDayNew(date.day.toString(), isSelected, isToday: isToday),
                        ],
                    );
                },
            ),
        ),
      ],
    );
  }

  // Removed _buildDynamicGrid as it's no longer needed for this strip view

  Widget _buildCalendarDayNew(String date, bool isSelected, {bool isToday = false}) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFC06C84) : (isToday ? const Color(0xFFE8B6CC).withOpacity(0.5) : Colors.transparent),
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
              child: const Icon(Icons.check_circle, color: Color(0xFFC06C84), size: 16),
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
          // Spacing for alignment (Back button removed)
          const SizedBox(width: 44),
          
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

  Widget _buildCycleStatus(int currentDay, int periodLength, int fertileStart, int fertileEnd, int cycleLength) {
    String title = "";
    String subtitle = "";

    if (currentDay <= periodLength) {
      title = "Period";
      int daysLeft = periodLength - currentDay;
      subtitle = "Day $currentDay • ${daysLeft == 0 ? 'Last day' : '$daysLeft days left'}";
    } else if (currentDay < fertileStart) {
      title = "Follicular Phase";
      int daysUntilFertile = fertileStart - currentDay;
      subtitle = "$daysUntilFertile days until fertile window";
    } else if (currentDay >= fertileStart && currentDay <= fertileEnd) {
      title = "Fertile Window";
      // Ovulation is fertileEnd - 1 typically (start, ..., ov, end)
      // Actually fertileEnd is ovulation + 1. So Ovulation = fertileEnd - 1.
      int ovulationDay = fertileEnd - 1;
      if (currentDay == ovulationDay) {
        subtitle = "Ovulation Day 🥚";
      } else {
        subtitle = "High chance of pregnancy";
      }
    } else if (currentDay <= cycleLength) {
      title = "Luteal Phase";
      int daysUntilPeriod = cycleLength - currentDay;
      subtitle = "$daysUntilPeriod days until next period";
    } else {
      title = "Late";
      int daysLate = currentDay - cycleLength;
      subtitle = "Period is $daysLate days late";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: Color(0xFFC06C84), // Deep Pink/Red
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle, 
            style: TextStyle(
              fontWeight: FontWeight.w500, 
              fontSize: 12,
              color: Colors.grey.shade700
            )
          ),
        ],
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final int cycleLength;
  final int periodLength;
  final int fertileStart;
  final int fertileEnd;
  final int currentDay;

  TimelinePainter({
    required this.cycleLength,
    required this.periodLength,
    required this.fertileStart,
    required this.fertileEnd,
    required this.currentDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Define Paint Styles
    final activePaint = Paint()
      ..color = const Color(0xFFFF005C) // Hot Pink (Active)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 // Thicker line as per design
      ..strokeCap = StrokeCap.round;

    final inactivePaint = Paint()
      ..color = const Color(0xFFF9C9DC) // Pale Pink (Inactive)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // 2. Define Curve Geometry (Quadratic Bezier)
    // Start (0, 20), Control (w/2, h+40), End (w, 20)
    // Simple smile curve
    final path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(size.width / 2, size.height + 40, size.width, 20);

    // 3. Draw Base Line (Inactive Color)
    canvas.drawPath(path, inactivePaint);

    // 4. Draw Active Progress Line (Active Color)
    // Calculate progress (0.0 to 1.0)
    double progress = currentDay / cycleLength;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0) progress = 0.0;

    // Use PathMetrics to extract sub-path for progress
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final extractPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractPath, activePaint);
    }

    // 5. Draw Checkpoint Dots matching Phase Transitions
    // Days to mark: Start(1), EndPeriod, StartFertile, EndFertile, EndCycle
    final List<int> milestoneDays = [
      1,
      periodLength,
      fertileStart,
      fertileEnd,
      cycleLength
    ];

    final dotPaintActive = Paint()..color = const Color(0xFFFF005C)..style = PaintingStyle.fill;
    final dotPaintInactive = Paint()..color = const Color(0xFFF9C9DC)..style = PaintingStyle.fill;

    for (int day in milestoneDays) {
      // Clamp day to valid range just in case
      if (day < 1) day = 1; 
      if (day > cycleLength) day = cycleLength;

      double t = day / cycleLength;
      Offset pos = _calculateQuadraticBezierPoint(t, size.width, size.height);
      
      bool isActive = t <= progress;
      canvas.drawCircle(pos, 6, isActive ? dotPaintActive : dotPaintInactive);
    }

    // 6. Draw Current Day Indicator (The "Burst" Circle)
    Offset indicatorPos = _calculateQuadraticBezierPoint(progress, size.width, size.height);
    _drawBurstIndicator(canvas, indicatorPos);
  }

  Offset _calculateQuadraticBezierPoint(double t, double w, double h) {
    // P0=(0,20), P1=(w/2, h+40), P2=(w,20)
    double u = 1 - t;
    double tt = t * t;
    double uu = u * u;

    double p0x = 0;
    double p0y = 20;

    double p1x = w / 2;
    double p1y = h + 40; 

    double p2x = w;
    double p2y = 20;

    double x = uu * p0x + 2 * u * t * p1x + tt * p2x;
    double y = uu * p0y + 2 * u * t * p1y + tt * p2y;

    return Offset(x, y);
  }

  void _drawBurstIndicator(Canvas canvas, Offset center) {
    // Inner filled circle
    final fillPaint = Paint()..color = const Color(0xFFFF005C)..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, fillPaint);

    // White Tick Marks ("Sunburst")
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final double radius = 8.0;
    final int tickCount = 8;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (int i = 0; i < tickCount; i++) {
        canvas.drawLine(const Offset(0, -4), const Offset(0, -9), tickPaint);
        canvas.rotate(2 * math.pi / tickCount);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
     return oldDelegate.currentDay != currentDay || 
            oldDelegate.cycleLength != cycleLength ||
            oldDelegate.periodLength != periodLength ||
            oldDelegate.fertileStart != fertileStart ||
            oldDelegate.fertileEnd != fertileEnd;
  }
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

    // GAP Config
    // StrokeWidth is 24. Radius is ~width/2 * 0.74. 
    // visual cap width is approx 7-8 degrees. 
    // To ensure a visual gap, we need gapRadians > 2 * capWidth ~ 15 degrees.
    final double gapRadians = _degreesToRadians(16); 

    // --- 1. Period Arc (Pink) ---
    final periodSweep = _daysToRadians(periodLength.toDouble(), degreesPerDay);
    _drawArc(canvas, center, radius * 0.74, startAngleOffset, periodSweep, gapRadians, const Color(0xFFFF005C), strokeWidth);

    // --- 2. Follicular (Infertile) Phase ---
    // From End of Period to Start of Fertile Window
    double follicularStartAngle = startAngleOffset + periodSweep;
    double follicularDays = (fertileStart - periodLength).toDouble();
    if (follicularDays > 0) {
      double follicularSweep = _daysToRadians(follicularDays, degreesPerDay);
       _drawArc(canvas, center, radius * 0.74, follicularStartAngle, follicularSweep, gapRadians, const Color(0xFFE0E0E0), strokeWidth);
    }

    // --- 3. Fertile Window (Purple) ---
    double fertileStartAngle = startAngleOffset + _daysToRadians(fertileStart.toDouble(), degreesPerDay); 
    double fertileDays = (fertileEnd - fertileStart).toDouble();
    double fertileSweep = _daysToRadians(fertileDays, degreesPerDay);
    
    _drawArc(canvas, center, radius * 0.74, fertileStartAngle, fertileSweep, gapRadians, const Color(0xFF5D5F9E), strokeWidth);

    // --- 4. Luteal Phase (Light Pink/Purple) ---
    double lutealStartAngle = startAngleOffset + _daysToRadians(fertileEnd.toDouble(), degreesPerDay);
    double lutealDays = (cycleLength - fertileEnd).toDouble();
    double lutealSweep = _daysToRadians(lutealDays, degreesPerDay);
    
    _drawArc(canvas, center, radius * 0.74, lutealStartAngle, lutealSweep, gapRadians, const Color(0xFFF9C9DC), strokeWidth); 

    // 5. Current Day Indicator
    if (animationProgress > 0.8) {
       double effectiveDay = currentDay.toDouble();
       if (effectiveDay > cycleLength) effectiveDay = cycleLength.toDouble();
       
       double currentDayAngle = startAngleOffset + _daysToRadians(effectiveDay, degreesPerDay);
       _drawCurrentDayIndicator(canvas, center, radius * 0.74, currentDayAngle);
    }
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double start, double totalSweep, double gap, Color color, double width) {
    // We want the visual arc to be inside 'totalSweep'.
    // With Round Caps, the visual arc extends beyond the path by (width/2) roughly.
    // So we subtract gap.
    
    double drawSweep = totalSweep - gap;
    
    // Safety check for very short phases
    // If a phase is shorter than the gap (e.g. 1 day vs 16 deg gap), 
    // we still might want to show *something* (a dot) or nothing?
    // User wants "phases", usually distinct.
    if (drawSweep <= 0.01) {
        // If it's too small, maybe just draw a tiny dot?
        // Or if it's 0 days, don't draw.
        // If it's 1 day but gap eats it, force a minimal sweep?
        if (totalSweep > 0.01) drawSweep = 0.01; 
        else return;
    }
    
    // We also need to center the arc within the allotted "totalSweep"?
    // Currently logic: Start + (Sweep-Gap).
    // The previous logic was: Start, draw (Sweep-Gap).
    // This leaves the gap at the END of the segment.
    // This implies Segment A ends at X - gap. Segment B starts at X. 
    // Distance (X - gap) to X is 'gap'.
    // If gap is large, visual gap appears.
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start, // Starts at the mathematical boundary
      drawSweep, // Ends 'gap' before the next boundary
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
  final int fertileStart;
  final int fertileEnd;

  const AnimatedCycleTracker({
    super.key,
    required this.currentDay,
    required this.periodLength,
    required this.fertileStart,
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
                _buildDynamicCenterImage(widget.currentDay, widget.periodLength, widget.fertileStart, widget.fertileEnd),

                // 2. Custom Painter (Animated Sweep)
                CustomPaint(
                  size: const Size(370, 370),
                  painter: CycleTrackerPainter(
                    currentDay: widget.currentDay,
                    periodLength: widget.periodLength,
                    fertileStart: widget.fertileStart,
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

  Widget _buildDynamicCenterImage(int currentDay, int periodLength, int fertileStart, int fertileEnd) {
    // Determine Phase & Visuals
    Color overlayColor = Colors.transparent;

    if (currentDay <= periodLength) {
      // Period
      overlayColor = Colors.white.withOpacity(0.4);
    } else if (currentDay >= fertileStart && currentDay <= fertileEnd) {
      // Fertile Window (Purple)
      overlayColor = Colors.blue.shade900.withOpacity(0.3);
    } else {
      // Unspecified / Follicular / Luteal (Default)
      // You could add a specific overlay for Follicular if desired, but transparent is cleaner for "normal" days
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
