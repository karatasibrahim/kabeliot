import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: Colors.white,
        ),

        // --- AppBar ---
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          titleTextStyle: AppTextStyles.headingSmall,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),

        // --- Metin Teması ---
        textTheme: ThemeData.dark().textTheme.copyWith(
          displayLarge: AppTextStyles.displayLarge,
          headlineLarge: AppTextStyles.headingLarge,
          headlineMedium: AppTextStyles.headingMedium,
          headlineSmall: AppTextStyles.headingSmall,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelSmall: AppTextStyles.labelSmall,
        ),

        // --- ElevatedButton ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 52.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            textStyle: AppTextStyles.labelLarge,
            elevation: 0,
          ),
        ),

        // --- TextButton ---
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // --- InputDecoration ---
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceElevated,
          labelStyle: AppTextStyles.bodySmall,
          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDisabled),
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
        ),

        // --- Card ---
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),

        // --- Divider ---
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),

        // --- SnackBar ---
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceElevated,
          contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: const BorderSide(color: AppColors.border),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // --- FloatingActionButton ---
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 8,
        ),

        // --- ProgressIndicator ---
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.border,
        ),

        // --- Icon ---
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: LightColors.background,
        colorScheme: const ColorScheme.light(
          primary: LightColors.primary,
          onPrimary: Colors.white,
          secondary: LightColors.accent,
          onSecondary: Colors.white,
          surface: LightColors.surface,
          onSurface: LightColors.textPrimary,
          error: LightColors.error,
          onError: Colors.white,
        ),

        // --- AppBar ---
        appBarTheme: AppBarTheme(
          backgroundColor: LightColors.surface,
          foregroundColor: LightColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: LightColors.border,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          titleTextStyle: AppTextStyles.headingSmall.copyWith(color: LightColors.textPrimary),
          iconTheme: const IconThemeData(color: LightColors.textPrimary),
        ),

        // --- Metin Teması ---
        textTheme: ThemeData.light().textTheme.copyWith(
          displayLarge: AppTextStyles.displayLarge.copyWith(color: LightColors.textPrimary),
          headlineLarge: AppTextStyles.headingLarge.copyWith(color: LightColors.textPrimary),
          headlineMedium: AppTextStyles.headingMedium.copyWith(color: LightColors.textPrimary),
          headlineSmall: AppTextStyles.headingSmall.copyWith(color: LightColors.textPrimary),
          bodyLarge: AppTextStyles.bodyLarge.copyWith(color: LightColors.textPrimary),
          bodyMedium: AppTextStyles.bodyMedium.copyWith(color: LightColors.textSecondary),
          bodySmall: AppTextStyles.bodySmall.copyWith(color: LightColors.textSecondary),
          labelLarge: AppTextStyles.labelLarge.copyWith(color: LightColors.textPrimary),
          labelSmall: AppTextStyles.labelSmall.copyWith(color: LightColors.textSecondary),
        ),

        // --- ElevatedButton ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: LightColors.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 52.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            textStyle: AppTextStyles.labelLarge,
            elevation: 0,
          ),
        ),

        // --- TextButton ---
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: LightColors.primary,
            textStyle: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // --- InputDecoration ---
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: LightColors.surfaceElevated,
          labelStyle: AppTextStyles.bodySmall.copyWith(color: LightColors.textSecondary),
          hintStyle: AppTextStyles.bodySmall.copyWith(color: LightColors.textDisabled),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: LightColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: LightColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: LightColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: LightColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: LightColors.error, width: 1.5),
          ),
        ),

        // --- Card ---
        cardTheme: CardThemeData(
          color: LightColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(color: LightColors.border, width: 1),
          ),
        ),

        // --- Divider ---
        dividerTheme: const DividerThemeData(color: LightColors.divider, thickness: 1),

        // --- SnackBar ---
        snackBarTheme: SnackBarThemeData(
          backgroundColor: LightColors.surface,
          contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: LightColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: const BorderSide(color: LightColors.border),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // --- FloatingActionButton ---
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: LightColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 4,
        ),

        // --- ProgressIndicator ---
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: LightColors.primary,
          linearTrackColor: LightColors.border,
        ),

        // --- Icon ---
        iconTheme: const IconThemeData(color: LightColors.textSecondary, size: 24),
      );
}
