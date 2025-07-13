import 'package:flutter/cupertino.dart';

/// iOS-spezifische Typografie für ein natives und modernes App-Erlebnis
class AppTypography {
  AppTypography._();

  // Verwenden der korrekten Namen für die SF Pro-Schriftfamilie
  static const String sfProDisplay = '.SF Pro Display';
  static const String sfProText = '.SF Pro Text';

  // === DYNAMIC TYPE STYLES (iOS Human Interface Guidelines) ===

  /// Große Titel (z.B. in Navigation Bars)
  static const TextStyle largeTitle = TextStyle(
    fontFamily: sfProDisplay,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
  );

  /// Titel 1
  static const TextStyle title1 = TextStyle(
    fontFamily: sfProDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
  );

  /// Titel 2
  static const TextStyle title2 = TextStyle(
    fontFamily: sfProDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
  );

  /// Titel 3
  static const TextStyle title3 = TextStyle(
    fontFamily: sfProText,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
  );

  /// Überschrift für Abschnitte
  static const TextStyle headline = TextStyle(
    fontFamily: sfProText,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  /// Standard-Textkörper
  static const TextStyle body = TextStyle(
    fontFamily: sfProText,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
  );

  /// Hervorgehobener Text
  static const TextStyle callout = TextStyle(
    fontFamily: sfProText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
  );

  /// Unterüberschriften
  static const TextStyle subhead = TextStyle(
    fontFamily: sfProText,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
  );

  /// Fußnoten, kleine Beschreibungen
  static const TextStyle footnote = TextStyle(
    fontFamily: sfProText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
  );

  /// Beschriftungen
  static const TextStyle caption1 = TextStyle(
    fontFamily: sfProText,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  // === APP-SPECIFIC STYLES ===

  /// Für große Zahlen (z.B. Kalorien auf dem Dashboard)
  static const TextStyle metricLarge = TextStyle(
    fontFamily: sfProDisplay,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.37,
  );

  /// Für Buttons
  static const TextStyle button = TextStyle(
    fontFamily: sfProText,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  /// Für Tab-Bar-Beschriftungen
  static const TextStyle tabLabel = TextStyle(
    fontFamily: sfProText,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
}
