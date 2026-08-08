import 'package:ascend/shared/design/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// Fonts: SpaceGrotesk for display/game numbers, Inter for UI body copy.
/// Both bundled as variable fonts.
abstract final class AppTypography {
  static const String displayFamily = 'SpaceGrotesk';
  static const String bodyFamily = 'Inter';

  static TextTheme build(Brightness brightness) {
    final onSurface = brightness == Brightness.dark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;
    final muted = brightness == Brightness.dark
        ? AppColors.textMuted
        : AppColors.lightTextMuted;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFamily,
        fontSize: 44,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFamily,
        fontSize: 32,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: onSurface,
      ),
      displaySmall: TextStyle(
        fontFamily: displayFamily,
        fontSize: 24,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFamily,
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: displayFamily,
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: muted,
      ),
    );
  }
}