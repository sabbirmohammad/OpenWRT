import 'dart:math' as math;
import 'package:flutter/material.dart';

class TrafficSparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;

  const TrafficSparkline({
    super.key,
    required this.data,
    required this.color,
    this.height = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          points: data,
          lineColor: color,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;

  _SparklinePainter({
    required this.points,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (points.isEmpty) {
      // Draw subtle flat baseline
      final baselinePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.2)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(0, size.height * 0.8),
        Offset(size.width, size.height * 0.8),
        baselinePaint,
      );
      return;
    }

    final double maxVal = points.fold<double>(0.0, (prev, val) => math.max(prev, val));
    final double safeMax = maxVal <= 0 ? 1.0 : maxVal;

    final path = Path();
    final fillPath = Path();

    final stepX = points.length == 1 ? size.width : size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      // Invert Y so highest value is at top (padding from top 4px, bottom 4px)
      final normalized = (points[i] / safeMax).clamp(0.0, 1.0);
      final y = size.height - (normalized * (size.height - 8)) - 4;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == points.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();

        // Draw active pulsing tip dot
        final dotPaint = Paint()..color = lineColor;
        final glowPaint = Paint()
          ..color = lineColor.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawCircle(Offset(x, y), 3.5, glowPaint);
        canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
      }
    }

    // Draw gradient fill under sparkline
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw sparkline stroke
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
