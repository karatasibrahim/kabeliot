import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';

/// Tam ekran yükleme overlay'i.
/// Stack içine sararak mevcut ekran üzerine gösterilir.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.85),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48.r,
              height: 48.r,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            if (message != null) ...[
              SizedBox(height: 16.h),
              Text(
                message!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
