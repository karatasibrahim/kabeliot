import 'package:flutter/material.dart';

/// Kabel Teknoloji IoT App — "Industrial Cyber" renk paleti
abstract final class AppColors {
  // --- Arka Planlar ---
  static const Color background = Color(0xFF0A0E1A); // Koyu lacivert-siyah
  static const Color surface = Color(0xFF111827); // Kart yüzeyi
  static const Color surfaceElevated = Color(0xFF1C2539); // Yükseltilmiş panel

  // --- Ana Marka Rengi ---
  static const Color primary = Color(0xFF0EA5E9); // Elektrik mavi
  static const Color primaryDark = Color(0xFF0284C7); // Hover/basılı
  static const Color primaryGlow = Color(0x330EA5E9); // Glow efekti (%20 opaklık)

  // --- Vurgu ---
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color accentGlow = Color(0x3306B6D4);

  // --- Semantik Renkler ---
  static const Color success = Color(0xFF10B981); // Cihaz online
  static const Color warning = Color(0xFFF59E0B); // Cihaz uyarı
  static const Color error = Color(0xFFEF4444); // Cihaz offline / hata
  static const Color info = Color(0xFF6366F1); // Bilgi

  // --- Metin ---
  static const Color textPrimary = Color(0xFFF1F5F9); // Neredeyse beyaz
  static const Color textSecondary = Color(0xFF94A3B8); // Gri-mavi
  static const Color textDisabled = Color(0xFF475569); // Devre dışı

  // --- Kenarlık / Ayırıcı ---
  static const Color border = Color(0xFF1E3A5F); // İnce mavi kenarlık
  static const Color divider = Color(0xFF1E293B);

  // --- Gradient Durakları ---
  static const Color gradientStart = Color(0xFF0A0E1A);
  static const Color gradientMid = Color(0xFF0F172A);
  static const Color gradientEnd = Color(0xFF1E293B);
}

/// Kabel Teknoloji IoT App — Açık (Light) renk paleti
abstract final class LightColors {
  // --- Arka Planlar ---
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF1F5F9);

  // --- Ana Marka Rengi (light bg'de daha koyu — kontrast için) ---
  static const Color primary = Color(0xFF0284C7);
  static const Color primaryDark = Color(0xFF0369A1);
  static const Color primaryGlow = Color(0x200284C7);

  // --- Vurgu ---
  static const Color accent = Color(0xFF0891B2);
  static const Color accentGlow = Color(0x200891B2);

  // --- Semantik (biraz daha koyu — light bg kontrast) ---
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF4F46E5);

  // --- Metin ---
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textDisabled = Color(0xFF94A3B8);

  // --- Kenarlık / Ayırıcı ---
  static const Color border = Color(0xFFCBD5E1);
  static const Color divider = Color(0xFFE2E8F0);

  // --- Gradient Durakları ---
  static const Color gradientStart = Color(0xFFEFF6FF);
  static const Color gradientMid = Color(0xFFF8FAFC);
  static const Color gradientEnd = Color(0xFFE2E8F0);
}
