// / A widget that draws a circle with a blurred edge using a [CustomPainter].
import 'package:flutter/material.dart';

class CircleBlurWidget extends StatelessWidget {
  final Color color;
  final double diameter;
  final double blurSigma;

  const CircleBlurWidget({
    super.key,
    required this.color,
    required this.diameter,
    this.blurSigma = 30,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(diameter, diameter),
      painter: CircleBlurPainter(
        color: color,
        blurSigma: blurSigma,
      ),
    );
  }
}

class CircleBlurPainter extends CustomPainter {
  final Color color;
  final double blurSigma;

  CircleBlurPainter({required this.color, required this.blurSigma});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..color = color
      // 'normal' blur spreads both inside and outside the circle
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

    // Draw the circle at the center of the canvas
    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }

  @override
  bool shouldRepaint(CircleBlurPainter oldDelegate) => false;
}
