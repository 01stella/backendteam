import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _haloScale;
  late final Animation<double> _logoSettleScale;
  late final Animation<double> _logoLift;
  late final Animation<double> _taglineFade;
  late final Animation<double> _taglineSlide;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1700),
      vsync: this,
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.4,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 72,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 28,
      ),
    ]).animate(_controller);

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.46, curve: Curves.easeOut),
    );

    _haloScale = Tween<double>(begin: 0.78, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    _logoSettleScale = Tween<double>(begin: 1, end: 0.78).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 1, curve: Curves.easeInOutCubic),
      ),
    );

    _logoLift = Tween<double>(begin: 0, end: -86).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 1, curve: Curves.easeInOutCubic),
      ),
    );

    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 1, curve: Curves.easeOut),
    );

    _taglineSlide = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 1, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 3800), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, _, _) => const HomeScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _MinimalCafePainter(progress: _controller.value),
              ),
              Positioned.fill(
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, _logoLift.value),
                        child: FadeTransition(
                          opacity: _logoFade,
                          child: Transform.scale(
                            scale: _logoScale.value * _logoSettleScale.value,
                            child: _CircleLogoFrame(
                              haloScale: _haloScale.value,
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, 122 + _taglineSlide.value),
                        child: FadeTransition(
                          opacity: _taglineFade,
                          child: const Text(
                            'Perfectly brewed. Perfectly timed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 133, 102, 36),
                              fontSize: 22,
                              fontFamily: 'Verdana',
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CircleLogoFrame extends StatelessWidget {
  const _CircleLogoFrame({required this.haloScale});

  final double haloScale;

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final logoSize = shortestSide.clamp(250.0, 318.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.scale(
          scale: haloScale,
          child: Container(
            width: logoSize + 44,
            height: logoSize + 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF7E941F).withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
          ),
        ),
        Container(
          width: logoSize + 22,
          height: logoSize + 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFEFCF),
            border: Border.all(
              color: const Color.fromARGB(
                255,
                243,
                241,
                227,
              ).withValues(alpha: 0.62),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF465417).withValues(alpha: 0.18),
                blurRadius: 38,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: const Color(0xFFFFF4DA).withValues(alpha: 0.62),
                blurRadius: 16,
                offset: const Offset(-8, -8),
              ),
            ],
          ),
        ),
        Container(
          width: logoSize,
          height: logoSize,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFE8B8),
            border: Border.all(
              color: const Color(0xFFFFF6E2).withValues(alpha: 0.9),
              width: 6,
            ),
          ),
          child: ClipOval(
            child: Image.asset('assets/lumioralogo.png', fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

class _MinimalCafePainter extends CustomPainter {
  const _MinimalCafePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintSoftBands(canvas, size);
    _paintPattern(canvas, size);
    _paintAccentLines(canvas, size);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 245, 236, 197),
          Color.fromARGB(213, 202, 183, 85),
          Color.fromRGBO(111, 146, 34, 1),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, base);
  }

  void _paintSoftBands(Canvas canvas, Size size) {
    _drawBand(
      canvas,
      size,
      top: -0.08,
      height: 0.22,
      color: const Color(0xFF7E941F).withValues(alpha: 0.18),
      flip: false,
    );
    _drawBand(
      canvas,
      size,
      top: 0.76,
      height: 0.18,
      color: const Color(0xFF7E941F).withValues(alpha: 0.24),
      flip: true,
    );
  }

  void _drawBand(
    Canvas canvas,
    Size size, {
    required double top,
    required double height,
    required Color color,
    required bool flip,
  }) {
    final y = size.height * top;
    final h = size.height * height;
    final path = Path()..moveTo(0, y + (flip ? h * 0.6 : 0));

    path.cubicTo(
      size.width * 0.28,
      y + h * (flip ? 1.08 : 0.78),
      size.width * 0.66,
      y - h * (flip ? 0.08 : 0.18),
      size.width,
      y + h * (flip ? 0.42 : 0.54),
    );
    path
      ..lineTo(size.width, y + h * 1.7)
      ..cubicTo(
        size.width * 0.7,
        y + h * 1.28,
        size.width * 0.34,
        y + h * 1.74,
        0,
        y + h * 1.32,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  void _paintPattern(Canvas canvas, Size size) {
    final iconPaint = Paint()
      ..color = const Color(0xFF5F731A).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF7E941F).withValues(alpha: 0.28);

    const stepX = 92.0;
    const stepY = 112.0;
    for (double y = 36; y < size.height; y += stepY) {
      for (double x = 18; x < size.width + 42; x += stepX) {
        final phase = math.sin((x + y) * 0.012 + progress * math.pi) * 2;
        final selector = ((x / stepX).round() + (y / stepY).round()) % 3;

        canvas.save();
        canvas.translate(x + phase, y);
        canvas.rotate(math.sin((x - y) * 0.007) * 0.06);
        if (selector == 0) {
          _drawMinimalCup(canvas, iconPaint);
        } else if (selector == 1) {
          _drawMinimalBean(canvas, iconPaint);
        } else {
          _drawMinimalCroissant(canvas, iconPaint);
        }
        canvas.restore();
      }
    }

    for (double y = size.height * 0.58; y < size.height * 0.78; y += 16) {
      for (double x = 30; x < size.width - 20; x += 16) {
        canvas.drawCircle(Offset(x, y), 1.7, dotPaint);
      }
    }
  }

  void _paintAccentLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF7E941F).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 2; i++) {
      final inset = 34.0 + i * 12;
      canvas.drawArc(
        Rect.fromLTWH(
          inset,
          size.height * 0.28 + i * 8,
          size.width - inset * 2,
          size.width - inset * 2,
        ),
        math.pi * 1.08,
        math.pi * 0.84,
        false,
        linePaint,
      );
    }
  }

  void _drawMinimalCup(Canvas canvas, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 8, 30, 22),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.drawArc(
      const Rect.fromLTWH(24, 13, 15, 12),
      -math.pi / 2,
      math.pi,
      false,
      paint,
    );
    canvas.drawLine(const Offset(4, 35), const Offset(31, 35), paint);
    canvas.drawArc(
      const Rect.fromLTWH(7, -4, 7, 12),
      math.pi,
      math.pi,
      false,
      paint,
    );
    canvas.drawArc(
      const Rect.fromLTWH(18, -5, 7, 12),
      math.pi,
      math.pi,
      false,
      paint,
    );
  }

  void _drawMinimalBean(Canvas canvas, Paint paint) {
    canvas.drawOval(const Rect.fromLTWH(6, 0, 20, 33), paint);
    final path = Path()
      ..moveTo(16, 5)
      ..cubicTo(8, 13, 25, 20, 14, 29);
    canvas.drawPath(path, paint);
  }

  void _drawMinimalCroissant(Canvas canvas, Paint paint) {
    final path = Path()
      ..moveTo(0, 24)
      ..cubicTo(11, 6, 31, 4, 43, 23)
      ..cubicTo(27, 19, 15, 20, 0, 24);
    canvas.drawPath(path, paint);
    canvas.drawLine(const Offset(15, 10), const Offset(18, 23), paint);
    canvas.drawLine(const Offset(29, 10), const Offset(26, 23), paint);
  }

  @override
  bool shouldRepaint(covariant _MinimalCafePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
