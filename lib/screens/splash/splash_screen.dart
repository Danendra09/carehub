import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _waveProgressAnim;
  late Animation<double> _textOpacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 1. Logo pop up
    _logoScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // 2. Wave expanding
    _waveProgressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeInOutCubic),
      ),
    );

    // 3. Text fade in
    _textOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const LoginScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Wave Background Painter
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CustomPaint(
                  painter: _WaveBlobPainter(progress: _waveProgressAnim.value),
                ),
              ),

              // 2. Center Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),



                  // Title Text & Logo
                  Opacity(
                    opacity: _textOpacityAnim.value,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/icon.png',
                          width: 80,
                          height: 80,
                          // No color tint so it shows its original blue box and white house
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Care',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: 'Hub',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'CAHAYA ASUHAN RUANG EMPATI',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Bottom Text
                  Opacity(
                    opacity: _textOpacityAnim.value,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Text(
                        'Membangun Masa Depan Lebih Cerah',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
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
}

class _WaveBlobPainter extends CustomPainter {
  final double progress;

  _WaveBlobPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    // The maximum radius needed to cover the whole screen
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    
    // As progress goes from 0 to 1, the radius grows from 0 to maxRadius * 1.2
    final currentRadius = maxRadius * progress * 1.2;

    // Draw first blob (Light Blue 50% opacity)
    _drawBlob(
      canvas,
      center,
      currentRadius,
      progress,
      AppColors.primaryLight.withValues(alpha: 0.5),
      waveCount: 4,
      rotationSpeed: 2.0,
      amplitudeBase: 30.0,
    );

    // Draw second blob (Slightly darker blue, 40% opacity)
    _drawBlob(
      canvas,
      center,
      currentRadius * 0.85,
      progress,
      AppColors.primary.withValues(alpha: 0.15),
      waveCount: 3,
      rotationSpeed: -1.5,
      amplitudeBase: 40.0,
    );
  }

  void _drawBlob(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
    Color color, {
    required int waveCount,
    required double rotationSpeed,
    required double amplitudeBase,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const points = 60;
    
    // The perturbation (waviness) decreases as the blob expands
    // so it becomes a perfect circle when it fills the screen
    final amplitude = amplitudeBase * (1 - progress);
    final rotation = progress * math.pi * 2 * rotationSpeed;

    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * 2 * math.pi;
      
      // Calculate random-looking wave offset
      final offset = math.sin(angle * waveCount + rotation) * amplitude;
      final r = radius + offset;
      
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveBlobPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
