import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Yeniden kullanılabilir BoxDecoration ve InputDecoration factory'leri
abstract final class AppDecorations {
  // --- Kartlar ---
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      );

  static BoxDecoration get cardElevated => BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Cihaz kartı için uniform border (sol accent'i DeviceCardShell ile ekle)
  static BoxDecoration get deviceCard => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      );

  // --- Butonlar ---
  static BoxDecoration get primaryButton => BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGlow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // --- TextField ---
  static InputDecoration textField({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.bodySmall,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDisabled),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      );

  // --- Gradient Arka Plan ---
  static BoxDecoration get screenBackground => const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.8, -0.8),
          radius: 1.5,
          colors: [AppColors.gradientMid, AppColors.gradientStart],
        ),
      );
}
