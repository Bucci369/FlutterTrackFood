import 'package:flutter/cupertino.dart';

/// Modern und lebendige Farbpalette für die Food Tracking App
/// Basierend auf iOS Human Interface Guidelines und Food-App Best Practices
class AppColors {
  AppColors._();

  // === PRIMÄRE FARBEN ===
  /// Hauptfarbe - Beruhigendes Türkis für Gesundheitsaspekte
  static const Color primary = Color(0xFF34A0A4);
  static const Color primaryLight = Color(0xFF52B69A);
  static const Color primaryDark = Color(0xFF168B8F);

  // === SEKUNDÄRE FARBEN ===
  /// Lebendiges Grün für Gesundheit und Wohlbefinden
  static const Color secondary = Color(0xFF76C893);
  static const Color secondaryLight = Color(0xFF99D98C);
  static const Color secondaryDark = Color(0xFF52B69A);

  // === AKZENTFARBEN (für Food-Bereich) ===
  /// Appetitliche warme Farben für Mahlzeiten und Call-to-Actions
  static const Color accent = Color(0xFFFF8500); // Orange
  static const Color accentRed = Color(0xFFE63946); // Rot für wichtige Actions
  static const Color accentYellow = Color(0xFFFFD60A); // Gelb für Highlights

  // === NEUTRALE FARBEN ===
  /// iOS-System-Farben für nativen Look
  static const Color background = CupertinoColors.systemBackground;
  static const Color secondaryBackground = CupertinoColors.secondarySystemBackground;
  static const Color groupedBackground = CupertinoColors.systemGroupedBackground;
  
  static const Color label = CupertinoColors.label;
  static const Color secondaryLabel = CupertinoColors.secondaryLabel;
  static const Color tertiaryLabel = CupertinoColors.tertiaryLabel;

  // === FUNKTIONALE FARBEN ===
  static const Color success = Color(0xFF34C759); // iOS Grün
  static const Color warning = Color(0xFFFF9500); // iOS Orange
  static const Color error = Color(0xFFFF3B30); // iOS Rot
  static const Color info = Color(0xFF007AFF); // iOS Blau

  // === KALORIEN & MAKROS ===
  /// Spezifische Farben für Ernährungsdaten
  static const Color calories = Color(0xFF007AFF); // Blau
  static const Color protein = Color(0xFFE63946); // Rot
  static const Color carbs = Color(0xFFFFD60A); // Gelb
  static const Color fat = Color(0xFF34C759); // Grün
  static const Color fiber = Color(0xFF8E44AD); // Lila
  static const Color water = Color(0xFF00C9FF); // Cyan

  // === GRADIENTEN ===
  /// Für moderne UI-Elemente
  static const List<Color> primaryGradient = [
    Color(0xFF34A0A4),
    Color(0xFF52B69A),
  ];

  static const List<Color> healthGradient = [
    Color(0xFF76C893),
    Color(0xFF99D98C),
  ];

  static const List<Color> foodGradient = [
    Color(0xFFFF8500),
    Color(0xFFFFD60A),
  ];

  // === CHART FARBEN ===
  /// Für Diagramme und Visualisierungen
  static const List<Color> chartColors = [
    Color(0xFF34A0A4), // Primary
    Color(0xFF76C893), // Secondary
    Color(0xFFFF8500), // Accent
    Color(0xFFE63946), // Red
    Color(0xFFFFD60A), // Yellow
    Color(0xFF007AFF), // Blue
    Color(0xFF8E44AD), // Purple
    Color(0xFF34C759), // Green
  ];

  // === HELPER METHODS ===
  /// Gibt die passende Farbe für einen Makronährstoff zurück
  static Color getMacroColor(String macroType) {
    switch (macroType.toLowerCase()) {
      case 'protein':
      case 'eiweiß':
        return protein;
      case 'carbs':
      case 'carbohydrates':
      case 'kohlenhydrate':
        return carbs;
      case 'fat':
      case 'fett':
        return fat;
      case 'fiber':
      case 'ballaststoffe':
        return fiber;
      default:
        return label;
    }
  }

  /// Gibt eine Chart-Farbe basierend auf dem Index zurück
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}