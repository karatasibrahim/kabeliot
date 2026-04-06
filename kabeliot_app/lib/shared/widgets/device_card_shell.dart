import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';

/// Cihaz kartı için sol renkli accent şeridi + border radius + uniform border.
/// Flutter'da borderRadius + non-uniform Border aynı BoxDecoration'da kullanılamaz,
/// bu nedenle accent şeridini ClipRRect + Row ile çiziyoruz.
class DeviceCardShell extends StatelessWidget {
  const DeviceCardShell({
    super.key,
    required this.accentColor,
    required this.child,
    this.padding,
  });

  final Color accentColor;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sol accent şeridi
              Container(width: 4.w, color: accentColor),
              // İçerik
              Expanded(
                child: Padding(
                  padding: padding ?? EdgeInsets.all(16.r),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
