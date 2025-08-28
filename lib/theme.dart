import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// New color palette tokens (do not reuse older ones)
class AppColorsLight {
  static const primary = Color(0xFF276EF1);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFD9E6FF);
  static const onPrimaryContainer = Color(0xFF0B2559);
  static const secondary = Color(0xFF00A37A);
  static const onSecondary = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F8FA);
  static const onSurface = Color(0xFF1D2228);
  static const background = Color(0xFFFFFFFF);
  static const onBackground = Color(0xFF1D2228);
  static const error = Color(0xFFDC2626);
  static const onError = Color(0xFFFFFFFF);
  static const outline = Color(0xFFCFD6E4);
  static const subtle = Color(0xFFEEF2F9);
}

class AppColorsDark {
  static const primary = Color(0xFFAAD1FF);
  static const onPrimary = Color(0xFF0B2559);
  static const primaryContainer = Color(0xFF12316F);
  static const onPrimaryContainer = Color(0xFFD9E6FF);
  static const secondary = Color(0xFF5BE3B1);
  static const onSecondary = Color(0xFF073F2F);
  static const surface = Color(0xFF0E1116);
  static const onSurface = Color(0xFFE6E9EE);
  static const background = Color(0xFF0B0E13);
  static const onBackground = Color(0xFFE6E9EE);
  static const error = Color(0xFFFF6B6B);
  static const onError = Color(0xFF200000);
  static const outline = Color(0xFF273041);
  static const subtle = Color(0xFF151A22);
}

// Spacing & radius tokens
class AppSpacing { static const s4 = 4.0, s8 = 8.0, s12 = 12.0, s16 = 16.0, s20 = 20.0, s24 = 24.0, s32 = 32.0, s40 = 40.0; }
class AppRadii { static const r6 = 6.0, r10 = 10.0, r16 = 16.0, r24 = 24.0; }
class AppDurations { static const fast = Duration(milliseconds: 120), med = Duration(milliseconds: 240), slow = Duration(milliseconds: 420); }

class FontSizes {
  static const double displayLarge = 56.0;
  static const double displayMedium = 44.0;
  static const double displaySmall = 34.0;
  static const double headlineLarge = 30.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 20.0;
  static const double titleLarge = 20.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColorsLight.primary,
    onPrimary: AppColorsLight.onPrimary,
    primaryContainer: AppColorsLight.primaryContainer,
    onPrimaryContainer: AppColorsLight.onPrimaryContainer,
    secondary: AppColorsLight.secondary,
    onSecondary: AppColorsLight.onSecondary,
    surface: AppColorsLight.surface,
    onSurface: AppColorsLight.onSurface,
    background: AppColorsLight.background,
    onBackground: AppColorsLight.onBackground,
    error: AppColorsLight.error,
    onError: AppColorsLight.onError,
    outline: AppColorsLight.outline,
  ),
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColorsLight.background,
    foregroundColor: AppColorsLight.onBackground,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: const CardThemeData(
    color: AppColorsLight.background,
    margin: EdgeInsets.all(0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadii.r16))),
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: AppColorsLight.background,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadii.r16))),
  ),
  tabBarTheme: const TabBarThemeData(
    indicatorSize: TabBarIndicatorSize.label,
    labelPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(fontSize: FontSizes.displayLarge, fontWeight: FontWeight.w700, height: 1.1),
    displayMedium: GoogleFonts.inter(fontSize: FontSizes.displayMedium, fontWeight: FontWeight.w700, height: 1.14),
    displaySmall: GoogleFonts.inter(fontSize: FontSizes.displaySmall, fontWeight: FontWeight.w700, height: 1.18),
    headlineLarge: GoogleFonts.inter(fontSize: FontSizes.headlineLarge, fontWeight: FontWeight.w700, height: 1.2),
    headlineMedium: GoogleFonts.inter(fontSize: FontSizes.headlineMedium, fontWeight: FontWeight.w600, height: 1.25),
    headlineSmall: GoogleFonts.inter(fontSize: FontSizes.headlineSmall, fontWeight: FontWeight.w600, height: 1.28),
    titleLarge: GoogleFonts.inter(fontSize: FontSizes.titleLarge, fontWeight: FontWeight.w600, height: 1.3),
    titleMedium: GoogleFonts.inter(fontSize: FontSizes.titleMedium, fontWeight: FontWeight.w600, height: 1.35),
    titleSmall: GoogleFonts.inter(fontSize: FontSizes.titleSmall, fontWeight: FontWeight.w600, height: 1.35),
    labelLarge: GoogleFonts.inter(fontSize: FontSizes.labelLarge, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.inter(fontSize: FontSizes.labelMedium, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.inter(fontSize: FontSizes.labelSmall, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.inter(fontSize: FontSizes.bodyLarge, fontWeight: FontWeight.w400, height: 1.5),
    bodyMedium: GoogleFonts.inter(fontSize: FontSizes.bodyMedium, fontWeight: FontWeight.w400, height: 1.5),
    bodySmall: GoogleFonts.inter(fontSize: FontSizes.bodySmall, fontWeight: FontWeight.w400, height: 1.5),
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: AppColorsDark.primary,
    onPrimary: AppColorsDark.onPrimary,
    primaryContainer: AppColorsDark.primaryContainer,
    onPrimaryContainer: AppColorsDark.onPrimaryContainer,
    secondary: AppColorsDark.secondary,
    onSecondary: AppColorsDark.onSecondary,
    surface: AppColorsDark.surface,
    onSurface: AppColorsDark.onSurface,
    background: AppColorsDark.background,
    onBackground: AppColorsDark.onBackground,
    error: AppColorsDark.error,
    onError: AppColorsDark.onError,
    outline: AppColorsDark.outline,
  ),
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColorsDark.background,
    foregroundColor: AppColorsDark.onBackground,
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: const CardThemeData(
    color: AppColorsDark.subtle,
    margin: EdgeInsets.all(0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadii.r16))),
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: AppColorsDark.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadii.r16))),
  ),
  tabBarTheme: const TabBarThemeData(
    indicatorSize: TabBarIndicatorSize.label,
    labelPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(fontSize: FontSizes.displayLarge, fontWeight: FontWeight.w700, height: 1.1),
    displayMedium: GoogleFonts.inter(fontSize: FontSizes.displayMedium, fontWeight: FontWeight.w700, height: 1.14),
    displaySmall: GoogleFonts.inter(fontSize: FontSizes.displaySmall, fontWeight: FontWeight.w700, height: 1.18),
    headlineLarge: GoogleFonts.inter(fontSize: FontSizes.headlineLarge, fontWeight: FontWeight.w700, height: 1.2),
    headlineMedium: GoogleFonts.inter(fontSize: FontSizes.headlineMedium, fontWeight: FontWeight.w600, height: 1.25),
    headlineSmall: GoogleFonts.inter(fontSize: FontSizes.headlineSmall, fontWeight: FontWeight.w600, height: 1.28),
    titleLarge: GoogleFonts.inter(fontSize: FontSizes.titleLarge, fontWeight: FontWeight.w600, height: 1.3),
    titleMedium: GoogleFonts.inter(fontSize: FontSizes.titleMedium, fontWeight: FontWeight.w600, height: 1.35),
    titleSmall: GoogleFonts.inter(fontSize: FontSizes.titleSmall, fontWeight: FontWeight.w600, height: 1.35),
    labelLarge: GoogleFonts.inter(fontSize: FontSizes.labelLarge, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.inter(fontSize: FontSizes.labelMedium, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.inter(fontSize: FontSizes.labelSmall, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.inter(fontSize: FontSizes.bodyLarge, fontWeight: FontWeight.w400, height: 1.5),
    bodyMedium: GoogleFonts.inter(fontSize: FontSizes.bodyMedium, fontWeight: FontWeight.w400, height: 1.5),
    bodySmall: GoogleFonts.inter(fontSize: FontSizes.bodySmall, fontWeight: FontWeight.w400, height: 1.5),
  ),
);
