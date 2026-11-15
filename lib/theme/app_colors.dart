import 'package:flutter/material.dart';

class AppColors {
  /// Global toggle for active theme mode
  static bool isDark = false;

  static void setDarkMode(bool dark) {
    isDark = dark;
  }

  // --- Light Palette Constants ---
  static const Color lightPrimary = Color(0xFF005129);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFF086B3A);
  static const Color lightOnPrimaryContainer = Color(0xFF92E9AB);
  static const Color lightPrimaryFixed = Color(0xFF9EF5B7);
  static const Color lightPrimaryFixedDim = Color(0xFF83D99C);
  static const Color lightOnPrimaryFixed = Color(0xFF00210E);

  static const Color lightSecondary = Color(0xFF006D3F);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFF8AF9B4);
  static const Color lightOnSecondaryContainer = Color(0xFF007443);
  static const Color lightSecondaryFixed = Color(0xFF8AF9B4);
  static const Color lightSecondaryFixedDim = Color(0xFF6DDC9A);
  static const Color lightOnSecondaryFixed = Color(0xFF00210F);

  static const Color lightTertiary = Color(0xFF5B4200);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFF785800);
  static const Color lightOnTertiaryContainer = Color(0xFFFFD06F);
  static const Color lightTertiaryFixed = Color(0xFFFFDEA0);

  static const Color lightSurface = Color(0xFFEFFDF3);
  static const Color lightSurfaceDim = Color(0xFFCFDDD4);
  static const Color lightSurfaceBright = Color(0xFFEFFDF3);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFE9F7ED);
  static const Color lightSurfaceContainer = Color(0xFFE3F1E7);
  static const Color lightSurfaceContainerHigh = Color(0xFFDDECE2);
  static const Color lightSurfaceContainerHighest = Color(0xFFD8E6DC);

  static const Color lightOnSurface = Color(0xFF121E18);
  static const Color lightOnSurfaceVariant = Color(0xFF3F4940);
  static const Color lightOutline = Color(0xFF6F7A70);
  static const Color lightOutlineVariant = Color(0xFFBEC9BE);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF93000A);
  static const Color lightCardBorder = Color(0xFFE5ECE6);

  // --- Dark Palette Constants ---
  static const Color darkPrimary = Color(0xFF48D385);
  static const Color darkOnPrimary = Color(0xFF00391A);
  static const Color darkPrimaryContainer = Color(0xFF005228);
  static const Color darkOnPrimaryContainer = Color(0xFF9DF5B6);
  static const Color darkPrimaryFixed = Color(0xFF005228);
  static const Color darkPrimaryFixedDim = Color(0xFF83D99C);
  static const Color darkOnPrimaryFixed = Color(0xFF9DF5B6);

  static const Color darkSecondary = Color(0xFF57DF93);
  static const Color darkOnSecondary = Color(0xFF00381D);
  static const Color darkSecondaryContainer = Color(0xFF00522D);
  static const Color darkOnSecondaryContainer = Color(0xFF88F8B3);
  static const Color darkSecondaryFixed = Color(0xFF8AF9B4);
  static const Color darkSecondaryFixedDim = Color(0xFF6DDC9A);
  static const Color darkOnSecondaryFixed = Color(0xFF00210F);

  static const Color darkTertiary = Color(0xFFFFD06F);
  static const Color darkOnTertiary = Color(0xFF402E00);
  static const Color darkTertiaryContainer = Color(0xFF5B4200);
  static const Color darkOnTertiaryContainer = Color(0xFFFFDEA0);
  static const Color darkTertiaryFixed = Color(0xFFFFDEA0);

  static const Color darkSurface = Color(0xFF101613);
  static const Color darkSurfaceDim = Color(0xFF0C110F);
  static const Color darkSurfaceBright = Color(0xFF1A241F);
  static const Color darkSurfaceContainerLowest = Color(0xFF151D19);
  static const Color darkSurfaceContainerLow = Color(0xFF1A2520);
  static const Color darkSurfaceContainer = Color(0xFF202C26);
  static const Color darkSurfaceContainerHigh = Color(0xFF26342D);
  static const Color darkSurfaceContainerHighest = Color(0xFF2D3C34);

  static const Color darkOnSurface = Color(0xFFE8ECE9);
  static const Color darkOnSurfaceVariant = Color(0xFFA5B4AB);
  static const Color darkOutline = Color(0xFF8B9B90);
  static const Color darkOutlineVariant = Color(0xFF33433A);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);
  static const Color darkCardBorder = Color(0xFF2C3C33);

  // --- Dynamic Adaptive Getters ---
  static Color get primary => isDark ? darkPrimary : lightPrimary;
  static Color get onPrimary => isDark ? darkOnPrimary : lightOnPrimary;
  static Color get primaryContainer => isDark ? darkPrimaryContainer : lightPrimaryContainer;
  static Color get onPrimaryContainer => isDark ? darkOnPrimaryContainer : lightOnPrimaryContainer;
  static Color get primaryFixed => isDark ? darkPrimaryFixed : lightPrimaryFixed;
  static Color get primaryFixedDim => isDark ? darkPrimaryFixedDim : lightPrimaryFixedDim;
  static Color get onPrimaryFixed => isDark ? darkOnPrimaryFixed : lightOnPrimaryFixed;

  static Color get secondary => isDark ? darkSecondary : lightSecondary;
  static Color get onSecondary => isDark ? darkOnSecondary : lightOnSecondary;
  static Color get secondaryContainer => isDark ? darkSecondaryContainer : lightSecondaryContainer;
  static Color get onSecondaryContainer => isDark ? darkOnSecondaryContainer : lightOnSecondaryContainer;
  static Color get secondaryFixed => isDark ? darkSecondaryFixed : lightSecondaryFixed;
  static Color get secondaryFixedDim => isDark ? darkSecondaryFixedDim : lightSecondaryFixedDim;
  static Color get onSecondaryFixed => isDark ? darkOnSecondaryFixed : lightOnSecondaryFixed;

  static Color get tertiary => isDark ? darkTertiary : lightTertiary;
  static Color get onTertiary => isDark ? darkOnTertiary : lightOnTertiary;
  static Color get tertiaryContainer => isDark ? darkTertiaryContainer : lightTertiaryContainer;
  static Color get onTertiaryContainer => isDark ? darkOnTertiaryContainer : lightOnTertiaryContainer;
  static Color get tertiaryFixed => isDark ? darkTertiaryFixed : lightTertiaryFixed;

  static Color get surface => isDark ? darkSurface : lightSurface;
  static Color get surfaceDim => isDark ? darkSurfaceDim : lightSurfaceDim;
  static Color get surfaceBright => isDark ? darkSurfaceBright : lightSurfaceBright;
  static Color get surfaceContainerLowest => isDark ? darkSurfaceContainerLowest : lightSurfaceContainerLowest;
  static Color get surfaceContainerLow => isDark ? darkSurfaceContainerLow : lightSurfaceContainerLow;
  static Color get surfaceContainer => isDark ? darkSurfaceContainer : lightSurfaceContainer;
  static Color get surfaceContainerHigh => isDark ? darkSurfaceContainerHigh : lightSurfaceContainerHigh;
  static Color get surfaceContainerHighest => isDark ? darkSurfaceContainerHighest : lightSurfaceContainerHighest;

  static Color get onSurface => isDark ? darkOnSurface : lightOnSurface;
  static Color get onSurfaceVariant => isDark ? darkOnSurfaceVariant : lightOnSurfaceVariant;
  static Color get outline => isDark ? darkOutline : lightOutline;
  static Color get outlineVariant => isDark ? darkOutlineVariant : lightOutlineVariant;

  static Color get error => isDark ? darkError : lightError;
  static Color get onError => isDark ? darkOnError : lightOnError;
  static Color get errorContainer => isDark ? darkErrorContainer : lightErrorContainer;
  static Color get onErrorContainer => isDark ? darkOnErrorContainer : lightOnErrorContainer;
  static Color get cardBorder => isDark ? darkCardBorder : lightCardBorder;
}
