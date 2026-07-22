import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF03192e),
        onPrimary: Color(0xFFffffff),
        primaryContainer: Color(0xFF1a2e44),
        onPrimaryContainer: Color(0xFF8296b0),
        secondary: Color(0xFF51606f),
        onSecondary: Color(0xFFffffff),
        secondaryContainer: Color(0xFFd2e1f3),
        onSecondaryContainer: Color(0xFF556473),
        tertiary: Color(0xFF14191b),
        onTertiary: Color(0xFFffffff),
        tertiaryContainer: Color(0xFF292d2f),
        onTertiaryContainer: Color(0xFF919497),
        error: Color(0xFFba1a1a),
        onError: Color(0xFFffffff),
        errorContainer: Color(0xFFffdad6),
        onErrorContainer: Color(0xFF93000a),
        surface: Color(0xFFf8f9fa),
        onSurface: Color(0xFF191c1d),
        surfaceContainerHighest: Color(0xFFe1e3e4),
        onSurfaceVariant: Color(0xFF43474d),
        outline: Color(0xFF74777d),
        outlineVariant: Color(0xFFc4c6cd),
      ),
      scaffoldBackgroundColor: const Color(0xFFf8f9fa),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 28, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 22),
        headlineSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w400, fontSize: 18),
        bodyMedium: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w400, fontSize: 16),
        bodySmall: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w400, fontSize: 14),
        labelLarge: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.5),
        labelSmall: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 11),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFffffff),
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFb3c7e0),
        onPrimary: Color(0xFF001e36),
        primaryContainer: Color(0xFF003258),
        onPrimaryContainer: Color(0xFFd1e5ff),
        secondary: Color(0xFFb6c8db),
        onSecondary: Color(0xFF1f303e),
        secondaryContainer: Color(0xFF364755),
        onSecondaryContainer: Color(0xFFd2e1f3),
        tertiary: Color(0xFFc5c6c9),
        onTertiary: Color(0xFF2c3032),
        tertiaryContainer: Color(0xFF434749),
        onTertiaryContainer: Color(0xFFe1e2e5),
        error: Color(0xFFffb4ab),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000a),
        onErrorContainer: Color(0xFFffdad6),
        surface: Color(0xFF111416),
        onSurface: Color(0xFFe1e3e4),
        surfaceContainerHighest: Color(0xFF2c2f31),
        onSurfaceVariant: Color(0xFFc4c6cd),
        outline: Color(0xFF8e9198),
        outlineVariant: Color(0xFF43474d),
      ),
      scaffoldBackgroundColor: const Color(0xFF111416),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 28, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 22),
        headlineSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w400, fontSize: 18),
        bodyMedium: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w400, fontSize: 16),
        bodySmall: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w400, fontSize: 14),
        labelLarge: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.5),
        labelSmall: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 11),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1a1c1e),
        elevation: 0,
      ),
    );
  }
}
