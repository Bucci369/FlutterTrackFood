import 'package:flutter/cupertino.dart';

/// iOS-spezifische Typografie für natives Aussehen und Verhalten
/// Basierend auf San Francisco Schriftart und Apple Human Interface Guidelines
class AppTypography {
  AppTypography._();

  // === SCHRIFTART-FAMILIE ===
  /// San Francisco - die iOS System-Schriftart
  static const String systemFont = '.SF Pro Text';
  static const String systemFontDisplay = '.SF Pro Display';
  
  // === LETTER SPACING ===
  /// iOS-spezifisches Letter Spacing für nativen Look
  static const double defaultLetterSpacing = -0.41;

  // === GRUNDLEGENDE TEXT-STYLES ===
  
  /// Große Titel (iOS Large Title Navigation)
  static const TextStyle largeTitle = TextStyle(
    fontFamily: systemFontDisplay,
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: defaultLetterSpacing,
    height: 1.1,
  );

  /// Standard Titel (iOS Title)
  static const TextStyle title1 = TextStyle(
    fontFamily: systemFont,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: defaultLetterSpacing,
    height: 1.15,
  );

  /// Mittlere Titel (iOS Title 2)
  static const TextStyle title2 = TextStyle(
    fontFamily: systemFont,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: defaultLetterSpacing,
    height: 1.2,
  );

  /// Kleine Titel (iOS Title 3)
  static const TextStyle title3 = TextStyle(
    fontFamily: systemFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: defaultLetterSpacing,
    height: 1.25,
  );

  /// Überschriften (iOS Headline)
  static const TextStyle headline = TextStyle(
    fontFamily: systemFont,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: defaultLetterSpacing,
    height: 1.3,
  );

  /// Standard Body Text (iOS Body)
  static const TextStyle body = TextStyle(
    fontFamily: systemFont,
    fontSize: 17,
    fontWeight: FontWeight.normal,
    letterSpacing: defaultLetterSpacing,
    height: 1.4,
  );

  /// Kleinerer Body Text (iOS Callout)
  static const TextStyle callout = TextStyle(
    fontFamily: systemFont,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: defaultLetterSpacing,
    height: 1.4,
  );

  /// Untertitel (iOS Subhead)
  static const TextStyle subhead = TextStyle(
    fontFamily: systemFont,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    letterSpacing: defaultLetterSpacing,
    height: 1.35,
  );

  /// Fußnoten (iOS Footnote)
  static const TextStyle footnote = TextStyle(
    fontFamily: systemFont,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: defaultLetterSpacing,
    height: 1.3,
  );

  /// Sehr kleine Labels (iOS Caption 1)
  static const TextStyle caption1 = TextStyle(
    fontFamily: systemFont,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: defaultLetterSpacing,
    height: 1.3,
  );

  /// Kleinste Labels (iOS Caption 2)
  static const TextStyle caption2 = TextStyle(
    fontFamily: systemFont,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: defaultLetterSpacing,
    height: 1.2,
  );

  // === SPEZIELLE STYLES FÜR FOOD APP ===

  /// Für Kalorienzahlen und große Metriken
  static const TextStyle metric = TextStyle(
    fontFamily: systemFontDisplay,
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.8,
    height: 1.0,
  );

  /// Für kleinere Zahlen in Cards
  static const TextStyle cardNumber = TextStyle(
    fontFamily: systemFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: defaultLetterSpacing,
    height: 1.2,
  );

  /// Für Button-Text
  static const TextStyle button = TextStyle(
    fontFamily: systemFont,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: defaultLetterSpacing,
    height: 1.2,
  );

  /// Für Tab Bar Labels
  static const TextStyle tabLabel = TextStyle(
    fontFamily: systemFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: defaultLetterSpacing,
    height: 1.2,
  );

  /// Für Navigation Bar Titel
  static const TextStyle navTitle = TextStyle(
    fontFamily: systemFont,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: defaultLetterSpacing,
    height: 1.2,
  );

  // === HELPER METHODS ===

  /// Erstellt einen TextStyle mit spezifischer Farbe
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Erstellt einen TextStyle mit spezifischer Schriftgröße
  static TextStyle withSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }

  /// Erstellt einen TextStyle mit spezifischer Schriftstärke
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Gibt den passenden TextStyle für verschiedene UI-Elemente zurück
  static TextStyle getStyleForElement(String element) {
    switch (element.toLowerCase()) {
      case 'title':
      case 'heading':
        return title1;
      case 'subtitle':
        return title3;
      case 'body':
      case 'text':
        return body;
      case 'caption':
      case 'label':
        return caption1;
      case 'button':
        return button;
      case 'metric':
      case 'number':
        return metric;
      default:
        return body;
    }
  }
}