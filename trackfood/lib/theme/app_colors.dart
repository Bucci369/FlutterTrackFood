import 'package:flutter/cupertino.dart';

/// Modern und lebendige Farbpalette für die Food Tracking App
/// Inspiriert von führenden Apps wie Lifesum und Yazio
class AppColors {
  AppColors._();

  // === PRIMARY & SECONDARY ===
  static const Color primary = Color(0xFF2EC4B6);
  static const Color primaryLight = Color(0xFFCBF3F0);
  static const Color primaryDark = Color(0xFF0A9396);
  static const Color secondary = Color(0xFF3A86FF);

  // === ACCENT COLORS ===
  static const Color accentOrange = Color(0xFFFF9F1C);
  static const Color accentRed = Color(0xFFFF4D6D);
  static const Color accentYellow = Color(0xFFFFD166);

  // === NEUTRAL COLORS ===
  static const Color background = CupertinoColors.systemGroupedBackground;
  static const Color secondaryBackground =
      CupertinoColors.secondarySystemGroupedBackground;
  static const Color label = CupertinoColors.label;
  static const Color secondaryLabel = CupertinoColors.secondaryLabel;
  static const Color tertiaryLabel = CupertinoColors.tertiaryLabel;
  static const Color placeholder = CupertinoColors.placeholderText;
  static const Color separator = CupertinoColors.separator;
  static const Color fill = CupertinoColors.systemGrey5;

  // === FUNCTIONAL COLORS ===
  static const Color success = CupertinoColors.systemGreen;
  static const Color warning = CupertinoColors.systemOrange;
  static const Color error = CupertinoColors.systemRed;
  static const Color info = CupertinoColors.systemBlue;

  // === KALORIEN & MAKROS ===
  static const Color calories = Color(0xFF007AFF); // Blau
  static const Color proteinMacro = Color(0xFFE63946); // Rot
  static const Color carbsMacro = Color(0xFFFFD60A); // Gelb
  static const Color fatMacro = Color(0xFF34C759); // Grün
  static const Color fiber = Color(0xFF8E44AD); // Lila
  static const Color water = Color(0xFF00C9FF); // Cyan

  // === GRADIENTEN ===
  static const List<Color> primaryGradient = [primary, Color(0xFF0A9396)];
  static const List<Color> healthGradient = [
    Color(0xFF76C893),
    Color(0xFF99D98C),
  ];
  static const List<Color> foodGradient = [
    Color(0xFFFF8500),
    Color(0xFFFFD60A),
  ];

  // === CHART FARBEN ===
  static const List<Color> chartColors = [
    primary,
    secondary,
    accentOrange,
    accentRed,
    accentYellow,
    Color(0xFF007AFF), // Blue
    Color(0xFF8E44AD), // Purple
    Color(0xFF34C759), // Green
  ];

  // === HELPER METHODS ===
  static Color getMacroColor(String macroType) {
    switch (macroType.toLowerCase()) {
      case 'protein':
      case 'eiweiß':
        return proteinMacro;
      case 'carbs':
      case 'carbohydrates':
      case 'kohlenhydrate':
        return carbsMacro;
      case 'fat':
      case 'fett':
        return fatMacro;
      case 'fiber':
      case 'ballaststoffe':
        return fiber;
      default:
        return label;
    }
  }

  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}
