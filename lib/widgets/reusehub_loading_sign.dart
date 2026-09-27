import 'package:flutter/material.dart';
import 'dart:math';

class ReUseLoadingSign extends StatefulWidget {
  final double size;
  final String? message;
  final bool isDark;

  const ReUseLoadingSign({
    super.key,
    this.size = 70.0,
    this.message,
    this.isDark = true,
  });

  @override
  State<ReUseLoadingSign> createState() => _ReUseLoadingSignState();
}

class _ReUseLoadingSignState extends State<ReUseLoadingSign> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ReUseLoadingPainter(
                  progress: _controller.value,
                  isDark: widget.isDark,
                ),
              );
            },
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: widget.isDark ? Colors.white70 : const Color(0xFF1B3B2B),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReUseLoadingPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _ReUseLoadingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = size.width * 0.40;

    // 1. Outer Glowing Track
    final trackPaint = Paint()
      ..color = (isDark ? Colors.white12 : const Color(0xFF104B25).withOpacity(0.12))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;

    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    // 2. Animated Rotating Recycling Ring
    final double rotationAngle = progress * 2 * pi;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotationAngle);

    // Top Green Arrow Arc
    final topArcPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF2DC653), Color(0xFF107C41)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      -pi / 2,
      pi * 0.8,
      false,
      topArcPaint,
    );

    // Bottom Orange Accent Arc
    final botArcPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFFFFAA00), Color(0xFFFF7700)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      pi * 0.5,
      pi * 0.6,
      false,
      botArcPaint,
    );

    canvas.restore();

    // 3. Inner Pulsing Core (Factory / ReUse 'S' Center)
    final double pulse = 0.85 + (sin(progress * 2 * pi) * 0.15);
    final double coreR = size.width * 0.18 * pulse;

    final corePaint = Paint()
      ..color = isDark ? const Color(0xFF2DC653) : const Color(0xFF104B25)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), coreR, corePaint);

    // Core Spark / Sunburst Ray
    final sparkPaint = Paint()
      ..color = const Color(0xFFFFAA00)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(cx + coreR * 0.5, cy - coreR * 0.5),
      coreR * 0.35,
      sparkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ReUseLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
