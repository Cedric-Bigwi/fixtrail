import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Decorative campus skyline + sun for the hero cards.
class HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sun = Paint()..color = tint(AppColors.saffron, 0.95);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.28), 26, sun);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.28), 44,
        Paint()..color = tint(AppColors.saffron, 0.18));

    final far = Paint()..color = tint(Colors.white, 0.08);
    final near = Paint()..color = tint(Colors.white, 0.14);
    final w = size.width;
    final h = size.height;
    void block(double x, double bw, double bh, Paint p) => canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(x, h - bh, bw, bh),
            topLeft: const Radius.circular(6), topRight: const Radius.circular(6)),
        p);
    block(w * 0.46, 40, 90, far);
    block(w * 0.58, 52, 120, far);
    block(w * 0.74, 44, 100, far);
    block(w * 0.52, 36, 64, near);
    block(w * 0.66, 60, 84, near);
    block(w * 0.86, 40, 70, near);
    // windows
    final win = Paint()..color = tint(AppColors.saffron, 0.5);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        canvas.drawRect(
            Rect.fromLTWH(w * 0.595 + c * 14, h - 108 + r * 22, 7, 10), win);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
