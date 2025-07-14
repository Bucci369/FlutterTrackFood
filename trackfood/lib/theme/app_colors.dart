import 'package:flutter/cupertino.dart';

/// Modern und lebendige Farbpalette für die Food Tracking App
// Removing duplicate AppColors class
class AppColors {
  AppColors._();

  // === PRIMARY & SECONDARY (EXISTING) ===
  static const Color primary = Color.fromARGB(
    255,
    46,
    71,
    196,
  ); // Lebhaftes Türkis
  static const Color primaryLight = Color.fromARGB(
    255,
    212,
    203,
    243,
  ); // Helles Mint
  static const Color primaryDark = Color(0xFF0A9396); // Dunkles Zyan
  static const Color secondary = Color(0xFF3A86FF); // Kräftiges Blau

  // === ACCENT COLORS (EXISTING) ===
  static const Color accentOrange = Color(0xFFFF9F1C); // Sonniges Orange
  static const Color accentRed = Color(0xFFFF4D6D); // Leuchtendes Korallrot
  static const Color accentYellow = Color(0xFFFFD166); // Pastellgelb

  // === NEUTRAL COLORS (EXISTING) ===
  static const Color background = CupertinoColors.systemGroupedBackground;
  static const Color secondaryBackground =
      CupertinoColors.secondarySystemGroupedBackground;
  static const Color label = CupertinoColors.label;
  static const Color secondaryLabel = CupertinoColors.secondaryLabel;
  static const Color tertiaryLabel = CupertinoColors.tertiaryLabel;
  static const Color placeholder = CupertinoColors.placeholderText;
  static const Color separator = CupertinoColors.separator;
  static const Color fill = CupertinoColors.systemGrey5;

  // === iOS System Colors for native feel ===
  static const Color systemRed = CupertinoColors.systemRed;
  static const Color systemGreen = CupertinoColors.systemGreen;
  static const Color systemBlue = CupertinoColors.systemBlue;
  static const Color systemOrange = CupertinoColors.systemOrange;
  static const Color systemYellow = CupertinoColors.systemYellow;
  static const Color systemPink = CupertinoColors.systemPink;
  static const Color systemPurple = CupertinoColors.systemPurple;
  static const Color systemTeal = CupertinoColors.systemTeal;
  static const Color systemIndigo = CupertinoColors.systemIndigo;

  static const Color systemBackground = CupertinoColors.systemBackground;
  static const Color secondarySystemBackground =
      CupertinoColors.secondarySystemBackground;
  static const Color tertiarySystemBackground =
      CupertinoColors.tertiarySystemBackground;

  static const Color systemGroupedBackground =
      CupertinoColors.systemGroupedBackground;
  static const Color secondarySystemGroupedBackground =
      CupertinoColors.secondarySystemGroupedBackground;
  static const Color tertiarySystemGroupedBackground =
      CupertinoColors.tertiarySystemGroupedBackground;

  static const Color systemFill = CupertinoColors.systemFill;
  static const Color secondarySystemFill = CupertinoColors.secondarySystemFill;
  static const Color tertiarySystemFill = CupertinoColors.tertiarySystemFill;
  static const Color quaternarySystemFill =
      CupertinoColors.quaternarySystemFill;

  // === FUNCTIONAL COLORS (EXISTING) ===
  static const Color success = CupertinoColors.systemGreen;
  static const Color warning = CupertinoColors.systemOrange;
  static const Color error = CupertinoColors.systemRed;
  static const Color info = CupertinoColors.systemBlue;

  // === KALORIEN & MAKROS (EXISTING) ===
  static const Color calories = Color(0xFF007AFF); // Blau
  static const Color proteinMacro = Color(0xFFE63946); // Rot
  static const Color carbsMacro = Color(0xFFFFD60A); // Gelb
  static const Color fatMacro = Color(0xFF34C759); // Grün
  static const Color fiber = Color(0xFF8E44AD); // Lila
  static const Color sodiumMacro = Color(0xFF4285F4); // Blau

  // ----------------------------------------------------------------
  // === TRENDFARBEN & ERWEITERUNGEN 2024/2025 ===
  // ----------------------------------------------------------------

  // === ERDIGE & NATURNAHE PALETTE (TREND 2025) ===
  /// Beruhigende, erdige Töne für Hintergründe oder Wellness-Bereiche.
  static const Color earthyBrown = Color(0xFF6D4C41); // Schokoladenbraun
  static const Color oliveGreen = Color(0xFF808000); // Olivgrün
  static const Color terracotta = Color(0xFFE2725B); // Terrakotta
  static const Color sandyBeige = Color(0xFFF4A460); // Sandiges Beige

  // === DIGITALE & LEBENDIGE PALETTE (TREND 2024) ===
  /// Kräftige, optimistische Farben für Akzente, Buttons oder Gamification.
  static const Color digitalTeal = Color(0xFF00AFAA); // Digitales Türkis
  static const Color cyberLime = Color(0xFFCCFF00); // Cyber-Limette
  static const Color radiantOrchid = Color(0xFFD946EF); // Leuchtende Orchidee

  // === SANFTE PASTELLTÖNE (TREND 2024/25) ===
  /// Weiche, freundliche Farben, ideal für Onboarding oder leere Zustände.
  static const Color pastelPeach = Color(
    0xFFFFE5B4,
  ); // Pastell-Pfirsich (ähnlich "Peach Fuzz")
  static const Color sereneBlue = Color(0xFFADD8E6); // Heiteres Hellblau
  static const Color lavenderMist = Color(0xFFE6E6FA); // Lavendelnebel

  // === GRADIENTEN (ERWEITERT) ===
  static const List<Color> primaryGradient = [primary, Color(0xFF0A9396)];
  static const List<Color> healthGradient = [
    Color(0xFF76C893),
    Color(0xFF99D98C),
  ];
  static const List<Color> foodGradient = [
    Color(0xFFFF8500),
    Color(0xFFFFD60A),
  ];

  /// Neuer Gradient für einen modernen, digitalen Look
  static const List<Color> digitalWaveGradient = [secondary, digitalTeal];

  /// Neuer Gradient für Entspannung und Wellness
  static const List<Color> sereneSkyGradient = [sereneBlue, Color(0xFFB0E0E6)];

  // === CHART FARBEN (ERWEITERT) ===
  /// Deine bestehende Palette, ergänzt um die neuen Trendfarben für mehr Vielfalt.
  static const List<Color> chartColors = [
    primary,
    secondary,
    accentOrange,
    accentRed,
    accentYellow,
    digitalTeal,
    radiantOrchid,
    oliveGreen,
    terracotta,
    cyberLime,
  ];

  // === HELPER METHODS (EXISTING & ERWEITERT) ===
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
