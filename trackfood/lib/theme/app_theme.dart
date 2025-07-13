import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Import Material
import 'app_colors.dart';
import 'app_typography.dart';

/// Zentrales App-Theme, das ein modernes und natives iOS-Design umsetzt.
class AppTheme {
  AppTheme._();

  // === MATERIAL THEME ===
  /// Helles Material-Theme, das die Cupertino-Ästhetik widerspiegelt.
  static ThemeData get materialLightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.secondaryBackground,
      error: AppColors.systemRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondaryBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
    cupertinoOverrideTheme:
        lightTheme, // Use Cupertino theme for Cupertino widgets
  );

  /// Dunkles Theme für die App
  static CupertinoThemeData get darkTheme => CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color.fromARGB(255, 69, 101, 204),
    scaffoldBackgroundColor: CupertinoColors.black,
    barBackgroundColor: CupertinoColors.darkBackgroundGray.withOpacity(0.85),
    textTheme: const CupertinoTextThemeData(
      textStyle: AppTypography.body,
      actionTextStyle: AppTypography.button,
      tabLabelTextStyle: AppTypography.tabLabel,
      navTitleTextStyle: AppTypography.headline,
      navLargeTitleTextStyle: AppTypography.largeTitle,
      pickerTextStyle: AppTypography.body,
      dateTimePickerTextStyle: AppTypography.body,
    ),
  );

  /// Helles Theme für die App
  static CupertinoThemeData get lightTheme => CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: AppColors.secondaryBackground.withOpacity(0.8),
    textTheme: const CupertinoTextThemeData(
      textStyle: AppTypography.body,
      actionTextStyle: AppTypography.button,
      tabLabelTextStyle: AppTypography.tabLabel,
      navTitleTextStyle: AppTypography.headline,
      navLargeTitleTextStyle: AppTypography.largeTitle,
      pickerTextStyle: AppTypography.body,
      dateTimePickerTextStyle: AppTypography.body,
    ),
  );

  // === SPACING & SIZING ===
  static const double cornerRadiusS = 8.0;
  static const double cornerRadiusM = 12.0;
  static const double cornerRadiusL = 20.0;

  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;

  static const EdgeInsets pagePadding = EdgeInsets.all(paddingM);
  static const EdgeInsets cardPadding = EdgeInsets.all(paddingM);
  static const EdgeInsets horizontalPagePadding = EdgeInsets.symmetric(
    horizontal: paddingM,
  );

  // === BORDERS & SHADOWS ===
  static BorderRadius get borderRadiusM => BorderRadius.circular(cornerRadiusM);
  static BorderRadius get borderRadiusL => BorderRadius.circular(cornerRadiusL);

  /// Moderner, weicher Schatten für UI-Karten
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: CupertinoColors.systemGrey4.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // === COMMON WIDGET STYLES (DECORATIONS) ===

  /// Standard-Dekoration für Karten
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.secondaryBackground,
    borderRadius: borderRadiusM,
    boxShadow: cardShadow,
  );

  /// Dekoration für primäre Buttons
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    color: AppColors.primary,
    borderRadius: borderRadiusM,
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );

  /// Dekoration für Input-Felder
  static BoxDecoration get inputDecoration => BoxDecoration(
    color: AppColors.fill,
    borderRadius: BorderRadius.circular(cornerRadiusS),
    border: Border.all(color: AppColors.separator, width: 0.5),
  );

  // === ANIMATIONS ===
  static const Duration animDuration = Duration(milliseconds: 300);
  static const Curve animCurve = Curves.easeInOutCubic;
}
