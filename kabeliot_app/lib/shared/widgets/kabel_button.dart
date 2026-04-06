import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_text_styles.dart';

/// Kabel IoT — Ana CTA butonu.
/// Gradient arka plan, glow box shadow, loading state desteği.
class KabelButton extends StatelessWidget {
  const KabelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width ?? double.infinity,
        height: 52.h,
        decoration: isOutlined
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primary, width: 1.5),
                color: Colors.transparent,
              )
            : isDisabled
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: AppColors.border,
                  )
                : AppDecorations.primaryButton,
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOutlined ? AppColors.primary : Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 18.r,
                        color: isOutlined ? AppColors.primary : Colors.white,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isOutlined ? AppColors.primary : Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
