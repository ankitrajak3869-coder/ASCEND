import 'package:flutter/painting.dart' show Color;

/// Ascend color tokens.
///
/// Dark-first brand palette. Accent: violet→cyan gradient acts as the
/// primary identity; gold is reserved for coins/level milestones.
abstract final class AppColors {
  // Surfaces (dark-first)
  static const Color background = Color(0xFF0E1116);
  static const Color surface = Color(0xFF161A22);
  static const Color surfaceElevated = Color(0xFF1D2330);
  static const Color outline = Color(0xFF2A2F3A);

  // Text
  static const Color textPrimary = Color(0xFFF4F6FB);
  static const Color textMuted = Color(0xFF9AA3B2);

  // Brand + system
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryBright = Color(0xFF22D3EE);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);
  static const Color gold = Color(0xFFF5C044);

  // Light surfaces (secondary theme)
  static const Color lightBackground = Color(0xFFF7F8FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF0F2F7);
  static const Color lightOutline = Color(0xFFE0E4EC);
  static const Color lightTextPrimary = Color(0xFF12151D);
  static const Color lightTextMuted = Color(0xFF5C6470);
}