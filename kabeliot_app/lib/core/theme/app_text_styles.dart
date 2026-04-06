import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Uygulama genelinde kullanılan metin stilleri.
/// Inter — UI metinleri (assets/fonts/Inter.ttf)
/// JetBrainsMono — Cihaz ID'leri ve sensör değerleri (assets/fonts/JetBrainsMono.ttf)
abstract final class AppTextStyles {
  // --- Display ---
  static TextStyle get displayLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  // --- Başlıklar ---
  static TextStyle get headingLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get headingMedium => TextStyle(
        fontFamily: 'Inter',
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSmall => TextStyle(
        fontFamily: 'Inter',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // --- Gövde ---
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  // --- Etiketler ---
  static TextStyle get labelLarge => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: 'Inter',
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  // --- Monospace (Cihaz ID, sensör değerleri) ---
  static TextStyle get mono => TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.accent,
      );

  static TextStyle get monoSmall => TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );
}
