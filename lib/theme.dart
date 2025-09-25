import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class LightModeColors {
  static const lightPrimary = Color(0xFF2563EB);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFEBF4FF);
  static const lightOnPrimaryContainer = Color(0xFF1E40AF);
  static const lightSecondary = Color(0xFF6366F1);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightTertiary = Color(0xFF10B981);
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightError = Color(0xFFEF4444);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFEE2E2);
  static const lightOnErrorContainer = Color(0xFFDC2626);
  static const lightInversePrimary = Color(0xFF60A5FA);
  static const lightShadow = Color(0xFF000000);
  static const lightSurface = Color(0xFFFAFBFC);
  static const lightOnSurface = Color(0xFF1F2937);
  static const lightAppBarBackground = Color(0xFFFFFFFF);

  // Dashboard specific colors
  static const dashboardCardBackground = Color(0xFFFFFFFF);
  static const dashboardSidebarBackground = Color(0xFFF8FAFC);
  static const dashboardBorder = Color(0xFFE5E7EB);
  static const dashboardSuccess = Color(0xFF10B981);
  static const dashboardWarning = Color(0xFFF59E0B);
  static const dashboardDanger = Color(0xFFEF4444);
  static const dashboardInfo = Color(0xFF3B82F6);
}

class DarkModeColors {
  static const darkPrimary = Color(0xFFD4BCCF);
  static const darkOnPrimary = Color(0xFF38265C);
  static const darkPrimaryContainer = Color(0xFF4F3D74);
  static const darkOnPrimaryContainer = Color(0xFFEAE0FF);
  static const darkSecondary = Color(0xFFCDC3DC);
  static const darkOnSecondary = Color(0xFF34313F);
  static const darkTertiary = Color(0xFFF0B6C5);
  static const darkOnTertiary = Color(0xFF4A2530);
  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);
  static const darkInversePrimary = Color(0xFF684F8E);
  static const darkShadow = Color(0xFF000000);
  static const darkSurface = Color(0xFF121212);
  static const darkOnSurface = Color(0xFFE0E0E0);
  static const darkAppBarBackground = Color(0xFF4F3D74);
}


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


