import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:flutter_app/presentation/ui/onboarding/onboarding_content.dart';

/// Individual onboarding screen widget
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.content,
    this.isActive = false,
    super.key,
  });

  final OnboardingContent content;
  final bool isActive;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _breathingController;

  late Animation<double> _blobAnimation;
  late Animation<double> _topIconScaleAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;

  @override
  void initState() {
    super.initState();
    // Entrance Controller
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Continuous Floating/Dancing Controller
    // Repeats 0 -> 1 linearly for circular orbit calculation
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat();

    // 1. Blob Entrance: 0ms - 1350ms (Gentle Pop)
    _blobAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );

    // 2. Top Icon Entrance: 750ms - 3000ms (Ultra Fluid Slide)
    _topIconScaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOutBack),
    );

    // 3. Title: 400ms - 900ms
    _titleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    );

    // 4. Description: 500ms - 1000ms
    _descriptionAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    );

    if (widget.isActive) {
      _entranceController.forward();
    }
  }

  @override
  void didUpdateWidget(OnboardingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _entranceController.reset();
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Icon/Illustration Area
          _buildIcon(context),

          const Spacer(),

          // Title
          AnimatedBuilder(
            animation: _titleAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _titleAnimation.value)),
                child: Opacity(
                  opacity: _titleAnimation.value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Text(
              widget.content.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          AnimatedBuilder(
            animation: _descriptionAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - _descriptionAnimation.value)),
                child: Opacity(
                  opacity: _descriptionAnimation.value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Text(
              widget.content.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    // 1. Lottie Animation (Priority)
    if (widget.content.lottieAsset != null) {
      // Logic: The Lottie and The Blob are ONE unit.
      // They Pop in together (using _blobAnimation).
      // The Lottie "Dances" inside the Blob shape.
      
      return AnimatedBuilder(
        animation: _blobAnimation,
        builder: (context, child) {
          final double scale = _blobAnimation.value;
          final double opacity = scale.clamp(0.0, 1.0);
          
          return Transform.scale(
            scale: scale, // Pop In Effect
            child: Opacity(
              opacity: opacity,
              child: SizedBox(
                width: 312,
                height: 312,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Layer 0: Atmospheric Glow (Backlight) - ONLY in advanced mode
                    if (widget.content.useAdvancedBlending &&
                        (widget.content.lottieBlobColor != null || widget.content.secondaryLottieBlobColor != null))
                      Opacity(
                        opacity: 0.4 * scale,
                        child: Container(
                          width: 312,
                          height: 312,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (widget.content.lottieBlobColor ?? widget.content.secondaryLottieBlobColor ?? Colors.black)
                                    .withOpacity(0.5),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Layer 1: Base Blob (Gradient or Solid)
                    if (widget.content.iconBottom != null)
                      widget.content.secondaryLottieBlobColor != null
                          ? ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  widget.content.secondaryLottieBlobColor!,
                                  widget.content.lottieBlobColor ?? Colors.black,
                                ],
                              ).createShader(bounds),
                              blendMode: BlendMode.srcIn,
                              child: SvgPicture.asset(
                                widget.content.iconBottom!,
                                width: 312,
                                fit: BoxFit.contain,
                              ),
                            )
                          : SvgPicture.asset(
                              widget.content.iconBottom!,
                              width: 312,
                              fit: BoxFit.contain,
                              // Force Blob Background to merge with Lottie's background if provided
                              colorFilter: widget.content.lottieBlobColor != null
                                  ? ColorFilter.mode(
                                      widget.content.lottieBlobColor!,
                                      BlendMode.srcIn,
                                    )
                                  : null,
                            ),

                    // Layer 2: Lottie (Optionally Clipped, Danced, and optionally Feathered)
                    _buildLottieWithOptionalClip(scale),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    if (widget.content.iconBottom != null && widget.content.iconTop != null) {
      // Layered Animation for Special Items
      return SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Layer 1: Bottom (Blob) - Elastic Pop
            AnimatedBuilder(
              animation: _blobAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _blobAnimation.value,
                  child: Opacity(
                    opacity: _blobAnimation.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: SvgPicture.asset(
                widget.content.iconBottom!,
                width: 280,
                fit: BoxFit.contain,
              ),
            ),

            // Layer 2: Top (Icon) - Slide In from Top-Right + Dancing
            AnimatedBuilder(
              animation: Listenable.merge([_topIconScaleAnimation, _breathingController]),
              builder: (context, child) {
                // Entrance Slide: From Offset(200, -200) (Top-Right) w/ Elastic Overshoot
                final double entranceValue = _topIconScaleAnimation.value;
                // Move from Right (200) and Top (-200)
                final double slideOffsetX = 200 * (1 - entranceValue);
                final double slideOffsetY = -200 * (1 - entranceValue);
                
                final double t = _breathingController.value * 4 * math.pi;
                
                // X: Slower wide swing (15px)
                final double danceX = 15 * math.sin(t);
                // Y: Faster vertical bob (15px) - 1.5x frequency
                final double danceY = 15 * math.cos(t * 1.5);

                return Transform.translate(
                  // Combine entrance slide with wandering dance
                  offset: Offset(slideOffsetX + danceX, slideOffsetY + danceY),
                  child: Opacity(
                    opacity: entranceValue.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.5 + (0.5 * entranceValue),
                      child: child,
                    ),
                  ),
                );
              },
              child: SvgPicture.asset(
                widget.content.iconTop!,
                width: 120, // Adjust size as needed
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      );
    }

    // Default Fallback
    return AnimatedBuilder(
      animation: _blobAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * _blobAnimation.value),
          child: Opacity(
            opacity: _blobAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFFEEA5D9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(130),
            bottomLeft: Radius.circular(150),
            bottomRight: Radius.circular(80),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEEA5D9).withOpacity(0.3),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.content.icon,
            style: const TextStyle(fontSize: 100),
          ),
        ),
      ),
    );
  }
}

class BlobClipper extends CustomClipper<Path> {
  const BlobClipper();

  @override
  Path getClip(Size size) {
    // Path data from vector_1.svg (ViewBox 312x312)
    const String pathData =
        'M275.383 233.947C274.419 237.116 273.42 240.319 272.387 243.557C271.353 246.794 270.286 249.998 269.183 253.167C268.081 256.404 266.91 259.573 265.67 262.673C264.43 265.773 263.156 268.804 261.847 271.767C260.469 274.66 259.022 277.484 257.507 280.24C255.922 282.927 254.269 285.51 252.547 287.99C250.755 290.401 248.861 292.64 246.863 294.707C244.866 296.773 242.73 298.599 240.457 300.183C238.183 301.837 235.772 303.283 233.223 304.523C230.606 305.694 227.919 306.693 225.163 307.52C222.408 308.347 219.549 309.001 216.587 309.483C213.624 309.966 210.593 310.276 207.493 310.413C204.393 310.551 201.293 310.551 198.193 310.413C195.024 310.276 191.856 310.034 188.687 309.69C185.449 309.346 182.245 308.863 179.077 308.243C175.977 307.692 172.877 307.072 169.777 306.383C166.677 305.626 163.611 304.799 160.58 303.903C157.549 303.077 154.587 302.181 151.693 301.217C148.731 300.183 145.803 299.15 142.91 298.117C140.017 297.014 137.123 295.912 134.23 294.81C131.337 293.708 128.478 292.537 125.653 291.297C122.76 290.126 119.832 288.954 116.87 287.783C113.977 286.543 111.014 285.303 107.983 284.063C105.021 282.892 102.024 281.687 98.9933 280.447C95.8933 279.276 92.7588 278.104 89.5899 276.933C86.4211 275.762 83.2177 274.591 79.9799 273.42C76.7422 272.18 73.5388 270.974 70.3699 269.803C67.1322 268.563 63.9288 267.254 60.7599 265.877C57.591 264.568 54.4566 263.19 51.3566 261.743C48.2566 260.297 45.2599 258.747 42.3666 257.093C39.4733 255.44 36.6833 253.683 33.9966 251.823C31.3099 249.963 28.7266 247.966 26.2466 245.83C23.8355 243.694 21.5622 241.421 19.4266 239.01C17.3599 236.599 15.431 234.016 13.6399 231.26C11.9177 228.504 10.3333 225.68 8.8866 222.787C7.50882 219.824 6.26882 216.759 5.1666 213.59C4.13327 210.49 3.27216 207.287 2.58327 203.98C1.82549 200.742 1.27438 197.436 0.929935 194.06C0.654379 190.753 0.516602 187.412 0.516602 184.037C0.58549 180.661 0.792157 177.32 1.1366 174.013C1.54993 170.707 2.16994 167.434 2.9966 164.197C3.75438 160.959 4.71882 157.756 5.88994 154.587C6.99216 151.487 8.2666 148.421 9.71327 145.39C11.1599 142.29 12.7444 139.259 14.4666 136.297C16.1199 133.334 17.8422 130.372 19.6333 127.41C21.4933 124.517 23.3877 121.589 25.3166 118.627C27.3144 115.733 29.2777 112.806 31.2066 109.843C33.2044 106.881 35.1677 103.919 37.0966 100.957C39.0255 97.9944 40.9199 94.9978 42.7799 91.9667C44.6399 88.9356 46.431 85.87 48.1533 82.77C49.8755 79.67 51.5288 76.57 53.1133 73.47C54.6977 70.3011 56.2822 67.2011 57.8666 64.17C59.3822 61.07 60.9322 58.0389 62.5166 55.0767C64.0322 52.0456 65.5822 49.1522 67.1666 46.3967C68.8199 43.5722 70.4733 40.8511 72.1266 38.2333C73.8488 35.6844 75.6399 33.2733 77.4999 31C79.3599 28.7267 81.3233 26.6256 83.3899 24.6967C85.3877 22.7678 87.5577 21.0456 89.8999 19.53C92.2422 18.0144 94.6877 16.6711 97.2366 15.5C99.7855 14.3978 102.472 13.4678 105.297 12.71C108.121 11.8833 111.014 11.1944 113.977 10.6433C117.008 10.0922 120.108 9.64444 123.277 9.3C126.445 8.95555 129.718 8.68 133.093 8.47333C136.4 8.19777 139.775 7.95666 143.22 7.75C146.664 7.54333 150.178 7.33666 153.76 7.13C157.273 6.92333 160.821 6.64777 164.403 6.30333C168.054 6.02777 171.671 5.68333 175.253 5.27C178.904 4.78777 182.555 4.34 186.207 3.92666C189.858 3.44444 193.509 2.96222 197.16 2.48C200.811 2.06666 204.428 1.68777 208.01 1.34333C211.592 0.998885 215.174 0.757774 218.757 0.619996C222.27 0.482218 225.749 0.482218 229.193 0.619996C232.638 0.688885 236.048 0.96444 239.423 1.44666C242.73 1.86 246.002 2.48 249.24 3.30666C252.409 4.20222 255.509 5.30444 258.54 6.61333C261.571 7.92222 264.499 9.43777 267.323 11.16C270.217 12.8822 272.972 14.8111 275.59 16.9467C278.208 19.0822 280.722 21.39 283.133 23.87C285.544 26.2811 287.783 28.8644 289.85 31.62C291.986 34.3756 293.983 37.2689 295.843 40.3C297.634 43.2622 299.288 46.3278 300.803 49.4967C302.319 52.6656 303.662 55.9378 304.833 59.3133C306.004 62.62 306.969 65.9956 307.727 69.44C308.553 72.8156 309.173 76.26 309.587 79.7733C310 83.2178 310.275 86.6967 310.413 90.21C310.551 93.7233 310.551 97.2711 310.413 100.853C310.275 104.367 310 107.88 309.587 111.393C309.242 114.907 308.794 118.42 308.243 121.933C307.692 125.378 307.038 128.822 306.28 132.267C305.591 135.642 304.833 139.018 304.007 142.393C303.249 145.7 302.422 148.972 301.527 152.21C300.631 155.448 299.736 158.617 298.84 161.717C297.944 164.817 297.049 167.882 296.153 170.913C295.189 173.944 294.224 176.941 293.26 179.903C292.296 182.866 291.331 185.828 290.367 188.79C289.402 191.683 288.438 194.611 287.473 197.573C286.44 200.536 285.441 203.463 284.477 206.357C283.443 209.319 282.444 212.316 281.48 215.347C280.447 218.378 279.448 221.443 278.483 224.543C277.45 227.574 276.417 230.709 275.383 233.947Z';

    return parseSvgPathData(pathData);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CircleClipper extends CustomClipper<Path> {
  const CircleClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Painter to add a subtle, premium tactile grain texture to the blob area
class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Seeded for consistency
    final paint = Paint()..strokeWidth = 1.0;

    for (var i = 0; i < 1500; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Alternate between very faint white and black dots
      final isWhite = random.nextBool();
      paint.color = (isWhite ? Colors.white : Colors.black).withOpacity(0.04);

      canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension _OnboardingScreenStateExtensions on _OnboardingScreenState {
  Widget _buildLottieWithOptionalClip(double scale) {
    if (widget.content.iconBottom != null) {
      // Special handling for the third screen (Orb Portal)
      final bool isOrbPortal = widget.content.title == 'Track Your Wellness';
      
      return ClipPath(
        clipper: isOrbPortal ? const CircleClipper() : const BlobClipper(),
        child: _buildLottieContent(scale),
      );
    }
    return _buildLottieContent(scale);
  }

  Widget _buildLottieContent(double scale) {
    if (widget.content.useAdvancedBlending) {
      final bool isOrbPortal = widget.content.title == 'Track Your Wellness';

      return Stack(
        alignment: Alignment.center,
        children: [
          // Layer: Portal Glow (Ensures the edge of the circular boundary is soft)
          if (isOrbPortal)
            Opacity(
              opacity: 0.4 * scale,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.content.lottieBlobColor ?? const Color(0xFFC06C84)).withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

          // Layer: Floor Glow (Anchors the animation to the 'ground')
          Opacity(
            opacity: 0.15 * scale,
            child: Container(
              width: 300, 
              height: 40,
              margin: const EdgeInsets.only(top: 240),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: (widget.content.lottieBlobColor ?? const Color(0xFFC06C84)).withOpacity(0.3),
                    blurRadius: 100, // Even more diffuse
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          
          // Expansive Soft Mask Layer
          ShaderMask(
            shaderCallback: (rect) {
              return RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: const [Colors.black, Colors.transparent],
                stops: isOrbPortal ? const [0.5, 1.0] : const [0.2, 0.9], // SHARP center 50%, then fade
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                  stops: [0.0, 0.3, 0.7, 1.0], // Softer vertical fade for the Orb
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: _buildLottieLayer(scale),
            ),
          ),
          
          // Subtle Noise Overlay (Premium Texture)
          IgnorePointer(
            child: CustomPaint(
              painter: _NoisePainter(),
              size: const Size(312, 312),
            ),
          ),
        ],
      );
    }
    return _buildLottieLayer(scale);
  }

  Widget _buildLottieLayer(double popInScale) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, lottieChild) {
        final bool isOrbPortal = widget.content.title == 'Track Your Wellness';
        
        final double t = _breathingController.value * 4 * math.pi;
        // Subtler movement for the Orb (5px) vs others (10px)
        final double danceX = isOrbPortal ? 5 * math.sin(t) : 10 * math.sin(t);
        final double danceY = isOrbPortal ? 5 * math.cos(t * 1.5) : 10 * math.cos(t * 1.5);

        return Transform.translate(
          offset: Offset(danceX, danceY + (isOrbPortal ? 0 : 15)),
          child: Transform.scale(
            scale: isOrbPortal ? 0.9 : 1.1, // Full Cover needs slightly less scale to fit well
            child: lottieChild,
          ),
        );
      },
      child: Lottie.asset(
        widget.content.lottieAsset!,
        width: 312,
        height: 312,
        fit: widget.content.title == 'Track Your Wellness' ? BoxFit.cover : BoxFit.contain, // COVER: Hides straight edges
      ),
    );
  }
}
