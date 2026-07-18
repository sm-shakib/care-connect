import 'package:flutter/material.dart';

/// Centralized color tokens for the "Kindred Care System" design.
///
/// Source: DESIGN.md (Stitch export). Light-mode values are copied
/// verbatim from the design spec. Dark-mode values are NOT part of
/// the original export — they're generated as reasonable placeholders
/// (same hues, adjusted for dark backgrounds) until an official dark
/// palette is provided by design.
class AppColors {
  AppColors._();

  // ==================== LIGHT MODE ====================
  // Copied directly from DESIGN.md `colors:` block.

  static const Color surfaceLight = Color(0xFFF9F9F9);
  static const Color surfaceDimLight = Color(0xFFDADADA);
  static const Color surfaceBrightLight = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowLight = Color(0xFFF3F3F3);
  static const Color surfaceContainerLight = Color(0xFFEEEEEE);
  static const Color surfaceContainerHighLight = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighestLight = Color(0xFFE2E2E2);
  static const Color onSurfaceLight = Color(0xFF1A1C1C);
  static const Color onSurfaceVariantLight = Color(0xFF3C4A46);
  static const Color inverseSurfaceLight = Color(0xFF2F3131);
  static const Color inverseOnSurfaceLight = Color(0xFFF0F1F1);
  static const Color outlineLight = Color(0xFF6B7A76);
  static const Color outlineVariantLight = Color(0xFFBACAC5);
  static const Color surfaceTintLight = Color(0xFF006B5F);

  static const Color primaryLight = Color(0xFF006B5F);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFF2DD4BF);
  static const Color onPrimaryContainerLight = Color(0xFF00574D);
  static const Color inversePrimaryLight = Color(0xFF3CDDC7);

  static const Color secondaryLight = Color(0xFF4059AA);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFF8FA7FE);
  static const Color onSecondaryContainerLight = Color(0xFF1D3989);

  static const Color tertiaryLight = Color(0xFF006A63);
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFF77CDC3);
  static const Color onTertiaryContainerLight = Color(0xFF005751);

  static const Color errorLight = Color(0xFFBA1A1A);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color errorContainerLight = Color(0xFFFFDAD6);
  static const Color onErrorContainerLight = Color(0xFF93000A);

  static const Color primaryFixedLight = Color(0xFF62FAE3);
  static const Color primaryFixedDimLight = Color(0xFF3CDDC7);
  static const Color onPrimaryFixedLight = Color(0xFF00201C);
  static const Color onPrimaryFixedVariantLight = Color(0xFF005047);

  static const Color secondaryFixedLight = Color(0xFFDCE1FF);
  static const Color secondaryFixedDimLight = Color(0xFFB6C4FF);
  static const Color onSecondaryFixedLight = Color(0xFF00164E);
  static const Color onSecondaryFixedVariantLight = Color(0xFF264191);

  static const Color tertiaryFixedLight = Color(0xFF9CF2E8);
  static const Color tertiaryFixedDimLight = Color(0xFF80D5CB);
  static const Color onTertiaryFixedLight = Color(0xFF00201D);
  static const Color onTertiaryFixedVariantLight = Color(0xFF00504A);

  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color onBackgroundLight = Color(0xFF1A1C1C);
  static const Color surfaceVariantLight = Color(0xFFE2E2E2);

  // Named brand colors from the "Colors" narrative section of DESIGN.md
  // (kept as convenience aliases — same hex values as tokens above).
  static const Color primaryTeal = Color(0xFF2DD4BF); // = primaryContainerLight
  static const Color darkTeal = Color(0xFF0F766E); // headers/icons/active nav
  static const Color deepTrustBlue = Color(0xFF1E3A8A); // structural/informative text
  static const Color paleMint = Color(0xFFCCFBF1); // card/secondary surfaces
  static const Color warningRed = Color(0xFFDC2626); // SOS / emergency only
  static const Color offWhite = Color(0xFFFAFAFA); // base background

  // ==================== DARK MODE (generated placeholder) ====================
  // NOTE: Not part of the original Stitch export. These are derived by
  // keeping the same hues and swapping surface/text roles for a dark
  // background, following Material 3 conventions. Replace with an
  // official palette once Stitch exports one.

  static const Color surfaceDark = Color(0xFF121514);
  static const Color surfaceDimDark = Color(0xFF121514);
  static const Color surfaceBrightDark = Color(0xFF383B3A);
  static const Color surfaceContainerLowestDark = Color(0xFF0D0F0F);
  static const Color surfaceContainerLowDark = Color(0xFF1A1C1C);
  static const Color surfaceContainerDark = Color(0xFF1E2120);
  static const Color surfaceContainerHighDark = Color(0xFF282B2A);
  static const Color surfaceContainerHighestDark = Color(0xFF333635);
  static const Color onSurfaceDark = Color(0xFFE2E3E2);
  static const Color onSurfaceVariantDark = Color(0xFFBACAC5);
  static const Color inverseSurfaceDark = Color(0xFFE2E3E2);
  static const Color inverseOnSurfaceDark = Color(0xFF2F3131);
  static const Color outlineDark = Color(0xFF8F9A96);
  static const Color outlineVariantDark = Color(0xFF3C4A46);
  static const Color surfaceTintDark = Color(0xFF3CDDC7);

  static const Color primaryDark = Color(0xFF3CDDC7);
  static const Color onPrimaryDark = Color(0xFF00382F);
  static const Color primaryContainerDark = Color(0xFF00504A);
  static const Color onPrimaryContainerDark = Color(0xFF9CF2E8);
  static const Color inversePrimaryDark = Color(0xFF006B5F);

  static const Color secondaryDark = Color(0xFFB6C4FF);
  static const Color onSecondaryDark = Color(0xFF102C77);
  static const Color secondaryContainerDark = Color(0xFF264191);
  static const Color onSecondaryContainerDark = Color(0xFFDCE1FF);

  static const Color tertiaryDark = Color(0xFF80D5CB);
  static const Color onTertiaryDark = Color(0xFF00382F);
  static const Color tertiaryContainerDark = Color(0xFF00504A);
  static const Color onTertiaryContainerDark = Color(0xFF9CF2E8);

  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  static const Color primaryFixedDark = Color(0xFF62FAE3);
  static const Color primaryFixedDimDark = Color(0xFF3CDDC7);
  static const Color onPrimaryFixedDark = Color(0xFF00201C);
  static const Color onPrimaryFixedVariantDark = Color(0xFF005047);

  static const Color secondaryFixedDark = Color(0xFFDCE1FF);
  static const Color secondaryFixedDimDark = Color(0xFFB6C4FF);
  static const Color onSecondaryFixedDark = Color(0xFF00164E);
  static const Color onSecondaryFixedVariantDark = Color(0xFF264191);

  static const Color tertiaryFixedDark = Color(0xFF9CF2E8);
  static const Color tertiaryFixedDimDark = Color(0xFF80D5CB);
  static const Color onTertiaryFixedDark = Color(0xFF00201D);
  static const Color onTertiaryFixedVariantDark = Color(0xFF00504A);

  static const Color backgroundDark = Color(0xFF121514);
  static const Color onBackgroundDark = Color(0xFFE2E3E2);
  static const Color surfaceVariantDark = Color(0xFF3C4A46);

  // Warning red stays the same across modes — emergency color must be
  // instantly recognizable regardless of theme.
  static const Color warningRedDark = Color(0xFFFFB4AB);
}
