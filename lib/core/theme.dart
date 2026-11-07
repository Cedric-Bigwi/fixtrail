import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette: petrol teal + persimmon + saffron on warm paper (light)
/// or deep petrol (dark). Neutral colours are getters that follow [dark].
class AppColors {
  /// Set by the app root from ThemeProvider before the UI is built.
  static bool dark = false;
  static Color _p(int light, int dk) => Color(dark ? dk : light);

  // Theme-aware neutrals
  static Color get paper => _p(0xFFF5EFE4, 0xFF0C1A1C);
  static Color get card => _p(0xFFFFFCF7, 0xFF132629);
  static Color get field => _p(0xFFFFFFFF, 0xFF1A3235);
  static Color get ink => _p(0xFF10262B, 0xFFEEE8DC);
  static Color get muted => _p(0xFF6A7B7A, 0xFF9DB1AE);
  static Color get line => _p(0xFFE8DFCF, 0xFF26403F);
  static Color get sand => _p(0xFFEADFC9, 0xFF1F383A);
  static Color get teal => _p(0xFF0C5B5E, 0xFF2A918B);
  static Color get tealDeep => _p(0xFF08393C, 0xFF0A2B2E);

  // Brand accents (same in both themes)
  static const persimmon = Color(0xFFE4572E);
  static const saffron = Color(0xFFEFB24A);
  static const moss = Color(0xFF5F9B72);
  static const lilac = Color(0xFF7C6BB5);
}

Color tint(Color c, double opacity) =>
    c.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());

class AppText {
  static TextStyle display(double size, {Color? color}) => GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.ink,
      height: 1.12);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: AppColors.dark ? Brightness.dark : Brightness.light,
      surface: AppColors.card,
    ).copyWith(
      primary: AppColors.teal,
      secondary: AppColors.persimmon,
      onSurface: AppColors.ink,
    ),
  );
  final text = GoogleFonts.dmSansTextTheme(base.textTheme)
      .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: w),
      );

  return base.copyWith(
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.ink,
      titleTextStyle: AppText.display(22),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: AppColors.muted, fontSize: 14),
      border: border(AppColors.line),
      enabledBorder: border(AppColors.line),
      focusedBorder: border(AppColors.teal, 1.6),
      errorBorder: border(AppColors.persimmon),
      focusedErrorBorder: border(AppColors.persimmon, 1.6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        disabledBackgroundColor: tint(AppColors.teal, 0.65),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
