import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color primarySoft = Color(0xFFEDE9FE);

  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFEF3C7);

  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navActive = Color(0xFF7C3AED);
  static const Color navInactive = Color(0xFF9CA3AF);

  static const List<Color> primaryGradient = [
    Color(0xFF7C3AED),
    Color(0xFF8B5CF6),
  ];

  static BoxShadow get softShadow => BoxShadow(
        color: const Color(0xFF7C3AED).withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      );

  static BoxShadow get mediumShadow => BoxShadow(
        color: const Color(0xFF7C3AED).withOpacity(0.12),
        blurRadius: 30,
        offset: const Offset(0, 8),
      );
}