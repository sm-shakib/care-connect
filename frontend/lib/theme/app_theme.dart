import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Builds the app's light and dark [ThemeData] from [AppColors], following
/// the "Kindred Care System" design spec (DESIGN.md):
/// - Ultra-Accessible Modern style: high contrast, generous spacing,
///   minimum 14px text, 48px min touch targets.
/// - Rounded shapes (buttons pill-shaped / rounded-xl, cards rounded-lg).
/// - Atkinson Hyperlegible Next typeface for maximum legibility.
class AppTheme {
  AppTheme._();

  // Shared accessibility-driven constants from the design spec.
  static const double touchTargetMin = 48;
  static const double buttonHeightMin = 56;
  static const double cardRadius = 16; // rounded-lg (1rem)
  static const double buttonRadius = 24; // rounded-xl (1.5rem) — visually pill-like at button height

  // NOTE: 'Atkinson Hyperlegible Next' must be added to pubspec.yaml fonts
  // (or via google_fonts) for this fontFamily name to actually render;
  // otherwise Flutter silently falls back to the platform default.
  static const String fontFamily = 'AtkinsonHyperlegibleNext';

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      primaryContainer: AppColors.primaryContainerLight,
      onPrimaryContainer: AppColors.onPrimaryContainerLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.onSecondaryLight,
      secondaryContainer: AppColors.secondaryContainerLight,
      onSecondaryContainer: AppColors.onSecondaryContainerLight,
      tertiary: AppColors.tertiaryLight,
      onTertiary: AppColors.onTertiaryLight,
      tertiaryContainer: AppColors.tertiaryContainerLight,
      onTertiaryContainer: AppColors.onTertiaryContainerLight,
      error: AppColors.errorLight,
      onError: AppColors.onErrorLight,
      errorContainer: AppColors.errorContainerLight,
      onErrorContainer: AppColors.onErrorContainerLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      surfaceDim: AppColors.surfaceDimLight,
      surfaceBright: AppColors.surfaceBrightLight,
      surfaceContainerLowest: AppColors.surfaceContainerLowestLight,
      surfaceContainerLow: AppColors.surfaceContainerLowLight,
      surfaceContainer: AppColors.surfaceContainerLight,
      surfaceContainerHigh: AppColors.surfaceContainerHighLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
      outline: AppColors.outlineLight,
      outlineVariant: AppColors.outlineVariantLight,
      inverseSurface: AppColors.inverseSurfaceLight,
      onInverseSurface: AppColors.inverseOnSurfaceLight,
      inversePrimary: AppColors.inversePrimaryLight,
      surfaceTint: AppColors.surfaceTintLight,
    );

    return _buildTheme(colorScheme, AppColors.backgroundLight, AppColors.onBackgroundLight);
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,
      tertiary: AppColors.tertiaryDark,
      onTertiary: AppColors.onTertiaryDark,
      tertiaryContainer: AppColors.tertiaryContainerDark,
      onTertiaryContainer: AppColors.onTertiaryContainerDark,
      error: AppColors.errorDark,
      onError: AppColors.onErrorDark,
      errorContainer: AppColors.errorContainerDark,
      onErrorContainer: AppColors.onErrorContainerDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceDim: AppColors.surfaceDimDark,
      surfaceBright: AppColors.surfaceBrightDark,
      surfaceContainerLowest: AppColors.surfaceContainerLowestDark,
      surfaceContainerLow: AppColors.surfaceContainerLowDark,
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerHigh: AppColors.surfaceContainerHighDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineVariantDark,
      inverseSurface: AppColors.inverseSurfaceDark,
      onInverseSurface: AppColors.inverseOnSurfaceDark,
      inversePrimary: AppColors.inversePrimaryDark,
      surfaceTint: AppColors.surfaceTintDark,
    );

    return _buildTheme(colorScheme, AppColors.backgroundDark, AppColors.onBackgroundDark);
  }

  /// Shared theme construction so light/dark stay structurally identical —
  /// only the color values differ.
  static ThemeData _buildTheme(
      ColorScheme colorScheme,
      Color background,
      Color onBackground,
      ) {
    final textTheme = _buildTextTheme(onBackground);

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),

      // Buttons: min 56px height, bold 18px centered text, pill/rounded-xl shape.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(buttonHeightMin),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(buttonHeightMin),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.4),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(touchTargetMin, touchTargetMin),
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Cards: rounded-lg, subtle 1px border instead of heavy shadows
      // (per "Elevation & Depth" — avoids blurry shadows for aging eyes).
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Inputs: large text, thick 2px border when focused, persistent labels.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: textTheme.bodyMedium,
      ),

      // Bottom nav: Dark Teal active state, per spec.
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: AppColors.darkTeal,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
        type: BottomNavigationBarType.fixed,
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // 48x48 minimum hit box for icon buttons, per accessibility spec.
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(touchTargetMin, touchTargetMin),
        ),
      ),
    );
  }

  /// Typography scale copied from DESIGN.md `typography:` block.
  /// Font sizes never drop below 14px, per the accessibility spec.
  static TextTheme _buildTextTheme(Color onBackground) {
    return TextTheme(
      // headline-lg
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        color: onBackground,
      ),
      // headline-md
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        color: onBackground,
      ),
      // headline-sm
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 28 / 20,
        color: onBackground,
      ),
      // body-lg
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 28 / 18,
        color: onBackground,
      ),
      // body-md
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: onBackground,
      ),
      // label-lg
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 20 / 16,
        color: onBackground,
      ),
      // label-md
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 18 / 14,
        color: onBackground,
      ),
    );
  }

  /// headline-lg-mobile variant from DESIGN.md — use directly where a
  /// smaller headline is needed on narrow screens, e.g.:
  /// `Text('Title', style: AppTheme.headlineLargeMobile(context))`
  static TextStyle headlineLargeMobile(BuildContext context) {
    final onBackground = Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 36 / 28,
      color: onBackground,
    );
  }
}
