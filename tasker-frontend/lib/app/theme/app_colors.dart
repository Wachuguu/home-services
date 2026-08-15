import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color backgroundPrimary = Color(0xFF121212);
  static const Color backgroundSurface = Color(0xFF1E1E1E);
  static const Color backgroundElevated = Color(0xFF2C2C2C);
  
  static const Color borderSubtle = Color(0xFF333333);
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF757575);
  
  static const Color primaryBlue = Color(0xFF82B1FF);
  static const Color primaryBlueLight = Color(0xFFB3D4FF);
  
  static const Color accentTeal = Color(0xFF03DAC6);
  static const Color accentMutedBlue = Color(0xFF82B1FF);
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFCF6679);
  static const Color mPesaGreen = Color(0xFF00A651);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryBlue, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardShimmer = LinearGradient(
    colors: [backgroundElevated, borderSubtle],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGlow = LinearGradient(
    colors: [accentTeal, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
