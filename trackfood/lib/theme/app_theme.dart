import 'package:flutter/cupertino.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Zentrales App-Theme für konsistentes Design
/// Kombiniert Farben, Typografie und iOS-spezifische Styles
class AppTheme {
  AppTheme._();

  /// Haupt-Theme für die gesamte App
  static CupertinoThemeData get lightTheme => const CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    primaryContrastingColor: CupertinoColors.white,
    scaffoldBackgroundColor: AppColors.groupedBackground,
    barBackgroundColor: AppColors.background,
    textTheme: CupertinoTextThemeData(
      textStyle: AppTypography.body,
      actionTextStyle: AppTypography.button,
      tabLabelTextStyle: AppTypography.tabLabel,
      navTitleTextStyle: AppTypography.navTitle,
      navLargeTitleTextStyle: AppTypography.largeTitle,
      navActionTextStyle: TextStyle(
        fontFamily: AppTypography.systemFont,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: AppTypography.defaultLetterSpacing,
        color: AppColors.primary,
      ),
      pickerTextStyle: AppTypography.body,
      dateTimePickerTextStyle: AppTypography.body,
    ),
  );

  /// Dark Theme für die App (falls gewünscht)
  static CupertinoThemeData get darkTheme => const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryLight,
    primaryContrastingColor: CupertinoColors.black,
    scaffoldBackgroundColor: CupertinoColors.systemBackground,
    barBackgroundColor: CupertinoColors.systemBackground,
    textTheme: CupertinoTextThemeData(
      textStyle: AppTypography.body,
      actionTextStyle: AppTypography.button,
      tabLabelTextStyle: AppTypography.tabLabel,
      navTitleTextStyle: AppTypography.navTitle,
      navLargeTitleTextStyle: AppTypography.largeTitle,
      navActionTextStyle: TextStyle(
        fontFamily: AppTypography.systemFont,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: AppTypography.defaultLetterSpacing,
        color: AppColors.primaryLight,
      ),
      pickerTextStyle: AppTypography.body,
      dateTimePickerTextStyle: AppTypography.body,
    ),
  );

  // === BORDER RADIUS ===
  /// iOS-typische abgerundete Ecken
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 10.0;

  static BorderRadius get defaultBorderRadius => BorderRadius.circular(defaultRadius);
  static BorderRadius get smallBorderRadius => BorderRadius.circular(smallRadius);
  static BorderRadius get largeBorderRadius => BorderRadius.circular(largeRadius);
  static BorderRadius get cardBorderRadius => BorderRadius.circular(cardRadius);
  static BorderRadius get buttonBorderRadius => BorderRadius.circular(buttonRadius);

  // === PADDING & MARGINS ===
  /// Konsistente Abstände basierend auf iOS Guidelines
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const EdgeInsets defaultPadding = EdgeInsets.all(paddingM);
  static const EdgeInsets smallPadding = EdgeInsets.all(paddingS);
  static const EdgeInsets largePadding = EdgeInsets.all(paddingL);
  
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: paddingM);
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: paddingM);

  // === SCHATTEN ===
  /// iOS-typische Schatten für Karten und erhöhte Elemente
  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: CupertinoColors.systemGrey.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // === SPEZIELLE STYLES ===

  /// Container-Style für Karten
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.background,
    borderRadius: cardBorderRadius,
    boxShadow: cardShadow,
  );

  /// Container-Style für Input-Felder
  static BoxDecoration get inputDecoration => BoxDecoration(
    color: AppColors.secondaryBackground,
    borderRadius: smallBorderRadius,
    border: Border.all(
      color: CupertinoColors.systemGrey4,
      width: 1,
    ),
  );

  /// Button-Style für primäre Aktionen
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    color: AppColors.primary,
    borderRadius: buttonBorderRadius,
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Button-Style für sekundäre Aktionen
  static BoxDecoration get secondaryButtonDecoration => BoxDecoration(
    color: AppColors.secondaryBackground,
    borderRadius: buttonBorderRadius,
    border: Border.all(
      color: AppColors.primary,
      width: 1,
    ),
  );

  // === HELPER METHODS ===

  /// Erstellt eine Gradient-Dekoration
  static BoxDecoration gradientDecoration(List<Color> colors) => BoxDecoration(
    gradient: LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: defaultBorderRadius,
    boxShadow: defaultShadow,
  );

  /// Erstellt eine Karten-Dekoration mit spezifischer Farbe
  static BoxDecoration coloredCardDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: cardBorderRadius,
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Standard-Übergangsanimationen
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
}