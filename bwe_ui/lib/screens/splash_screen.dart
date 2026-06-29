import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration duration;

  const SplashScreen({
    Key? key,
    required this.onComplete,
    this.duration = const Duration(seconds: 6),
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _logoController;
  late Animation<double> _progressAnimation;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;

  String _currentStatus = 'INITIALIZING ENGINE';
  late Timer _statusTimer;

  final List<MapEntry<double, String>> _statusSteps = [
    const MapEntry(0.0, 'INITIALIZING ENGINE'),
    const MapEntry(0.22, 'CALIBRATING CORE'),
    const MapEntry(0.46, 'LOADING DOCUMENT MATRIX'),
    const MapEntry(0.72, 'COMPOSING WORKSPACE'),
    const MapEntry(0.97, 'READY'),
  ];

  @override
  void initState() {
    super.initState();

    // Progress animation (0-100% over 6 seconds)
    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Logo animation (fade in at 70%, slide up)
    _logoController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // Start animations
    _progressController.forward();

    // Logo appears at 70% progress
    Future.delayed(Duration(milliseconds: (widget.duration.inMilliseconds * 0.7).toInt()), () {
      if (mounted) {
        _logoController.forward();
      }
    });

    // Update status text based on progress
    _statusTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      final progress = _progressController.value;
      String newStatus = _statusSteps[0].value;
      for (final step in _statusSteps) {
        if (progress >= step.key) {
          newStatus = step.value;
        }
      }
      if (newStatus != _currentStatus) {
        setState(() {
          _currentStatus = newStatus;
        });
      }
    });

    // Complete after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _statusTimer.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _logoController.dispose();
    _statusTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.5, 0),
            radius: 1.2,
            colors: [
              const Color(0xFF0C0820),
              const Color(0xFF050308),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and Title
              SlideTransition(
                position: _logoSlide,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Column(
                    children: [
                      Text(
                        'BOUNDLESS',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFFEEF0F5),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFFA78BFA).withOpacity(0.6),
                                  blurRadius: 22,
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'WRITE',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFFEEF0F5).withOpacity(0.6),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2.0,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'UNIVERSAL DOCUMENT ENGINE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFA78BFA).withOpacity(0.78),
                              letterSpacing: 3.68,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Progress Bar
              SizedBox(
                width: 210,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Text(
                              _currentStatus,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: const Color(0xFFC6CCDE).withOpacity(0.5),
                                    letterSpacing: 2.72,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF).withOpacity(0.07),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: _progressAnimation.value,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _buildProgressColor(_progressAnimation.value),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Particle Animation Background
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ParticlePainter(
                          progress: _progressController.value,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.6,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _buildProgressColor(double progress) {
    // Transition from purple to blue based on progress
    if (progress < 0.5) {
      // Purple (#A78BFA)
      return const Color(0xFFA78BFA);
    } else {
      // Blend to Blue (#6EA8FF)
      final t = (progress - 0.5) * 2;
      return Color.lerp(
        const Color(0xFFA78BFA),
        const Color(0xFF6EA8FF),
        t,
      )!;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final double width;
  final double height;

  ParticlePainter({
    required this.progress,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;

    // Draw subtle particle effects
    final centerX = width / 2;
    final centerY = height / 2;

    // Draw concentric circles that expand with progress
    for (int i = 0; i < 3; i++) {
      final radius = 20 + (i * 30) + (progress * 100);
      final alpha = (1 - progress).clamp(0.0, 1.0) * (0.3 - i * 0.1);

      paint.strokeWidth = 1;
      paint.color = const Color(0xFFA78BFA).withOpacity(alpha);

      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
    }

    // Draw some radial lines
    const rayCount = 8;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 3.14159 * 2;
      final startRadius = 30;
      final endRadius = 100 + (progress * 150);
      final alpha = progress.clamp(0.0, 1.0) * 0.2;

      paint.strokeWidth = 1.5;
      paint.color = const Color(0xFF6EA8FF).withOpacity(alpha);

      final startX = centerX + (startRadius * (angle.cos()));
      final startY = centerY + (startRadius * (angle.sin()));
      final endX = centerX + (endRadius * (angle.cos()));
      final endY = centerY + (endRadius * (angle.sin()));

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
