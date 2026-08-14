import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color backgroundPrimary = Color(0xFF0B0F1A);
  static const Color backgroundSurface = Color(0xFF141B2D);
  static const Color backgroundElevated = Color(0xFF1E293B);
  
  static const Color borderSubtle = Color(0xFF2D3A50);
  
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF8B9DC3);
  static const Color textMuted = Color(0xFF4A5B7A);
  
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF60A5FA);
  
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentViolet = Color(0xFFA855F7);
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color mPesaGreen = Color(0xFF00A651);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryBlue, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardShimmer = LinearGradient(
    colors: [backgroundElevated, borderSubtle],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGlow = LinearGradient(
    colors: [accentPurple, Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
