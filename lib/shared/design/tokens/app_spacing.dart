import 'package:flutter/material.dart';

/// Cardinal direction: 4pt base grid, 8pt rhythm for game surfaces.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double huge = 64;
}

/// Corner radii.
abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

/// Card/system shadows (kept shallow; glow used separately for accents).
abstract final class AppShadows {
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(
      color: Color(0x55000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];
}