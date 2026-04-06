import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';

/// Arka planda devre kartı görünümü veren CustomPainter.
/// Noktalı grid + rastgele ince bağlantı çizgileri.
class IoTGridPainter extends CustomPainter {
  const IoTGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = AppColors.textDisabled.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final spacing = 32.r;
    final dotRadius = 1.5.r;

    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;

    // Nokta grid'i çiz
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final x = col * spacing;
        final y = row * spacing;
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }

    // Belirli noktalara bağlantı çizgileri ekle (devre görünümü)
    final rng = Random(42); // Sabit seed — tutarlı görünüm
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (rng.nextDouble() > 0.85) {
          final x1 = col * spacing;
          final y1 = row * spacing;
          // Yatay veya dikey bağlantı
          if (rng.nextBool() && col + 1 < cols) {
            canvas.drawLine(
              Offset(x1, y1),
              Offset(x1 + spacing, y1),
              linePaint,
            );
          } else if (row + 1 < rows) {
            canvas.drawLine(
              Offset(x1, y1),
              Offset(x1, y1 + spacing),
              linePaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
