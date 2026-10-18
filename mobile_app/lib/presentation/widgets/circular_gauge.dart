import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';

class CircularGauge extends StatelessWidget {
  final double value; // 0.0 to 100.0
  final String label;
  final String? subtitle;
  final double size;
  final Color? activeColor;

  const CircularGauge({
    super.key,
    required this.value,
    required this.label,
    this.subtitle,
    this.size = 96.0,
    this.activeColor,
  });

  Color _resolveColor(double val) {
    if (activeColor != null) return activeColor!;
    if (val < 60) return GlossyColors.emeraldMint;
    if (val < 85) return GlossyColors.amberWarm;
    return GlossyColors.roseCoral;
  }

  @override
  Widget build(BuildContext context) {
    final clampedVal = value.clamp(0.0, 100.0);
    final color = _resolveColor(clampedVal);

    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Track & Progress Arc
                CustomPaint(
                  size: Size(size, size),
                  painter: _GaugePainter(
                    percent: clampedVal / 100.0,
                    progressColor: color,
                    trackColor: GlossyColors.glassBorderDark,
                  ),
                ),
                // Center percentage text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${clampedVal.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: GlossyColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: GlossyColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color progressColor;
  final Color trackColor;

  _GaugePainter({
    required this.percent,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.085;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    const startAngle = -math.pi * 0.75;
    const totalSweep = math.pi * 1.5;

    // Track Paint
    final trackPaint = Paint()
      ..color = const Color(0x18FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      trackPaint,
    );

    // Progress Paint with soft gradient
    if (percent > 0) {
      final sweepAngle = totalSweep * percent;
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.progressColor != progressColor;
  }
}
