import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF4169E1);
  static const Color darkBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFF93C5FD);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color mintGreen = Color(0xFF6EE7B7);
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF1a237e);
  static const Color backgroundLight = Color(0xFF3949ab);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkBorder = Color(0xFF424242);
  static const Color darkDivider = Color(0xFF424242);

  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0BEC5);
  static const Color textDark = Color(0xFF263238);
  
  // Card Colors
  static const Color cardLight = Color(0xFFE3F2FD);
  static const Color cardWhite = Color(0xFFFFFFFF);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1a237e),
      Color(0xFF3949ab),
      Color(0xFF5e92f3),
    ],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF121212),
      Color(0xFF1E1E1E),
      Color(0xFF2A2A2A),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5e92f3),
      Color(0xFF4169E1),
    ],
  );
}
