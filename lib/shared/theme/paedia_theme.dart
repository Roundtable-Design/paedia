import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'paedia_colors.dart';
import 'paedia_tokens.dart';

/// Material 3 theme for Paedia with brand tokens.
abstract final class PaediaTheme {
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;
    final tokens = isDark ? PaediaTokens.dark : PaediaTokens.light;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: [tokens],
    );

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme(base.textTheme, colorScheme.onSurface),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.7),
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.7),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
    );
  }

  static ColorScheme get _darkColorScheme => const ColorScheme.dark(
        primary: PaediaColors.primary,
        onPrimary: Colors.white,
        secondary: PaediaColors.secondary,
        onSecondary: Colors.white,
        tertiary: PaediaColors.tertiary,
        surface: PaediaColors.surfaceDark,
        onSurface: PaediaColors.onSurfaceDark,
        onSurfaceVariant: PaediaColors.onSurfaceVariantDark,
        error: PaediaColors.error,
        onError: Colors.white,
      );

  static ColorScheme get _lightColorScheme => const ColorScheme.light(
        primary: PaediaColors.primary,
        onPrimary: Colors.white,
        secondary: PaediaColors.secondary,
        onSecondary: Colors.white,
        tertiary: PaediaColors.tertiary,
        surface: PaediaColors.surfaceLight,
        onSurface: PaediaColors.onSurfaceLight,
        onSurfaceVariant: PaediaColors.onSurfaceVariantLight,
        error: PaediaColors.error,
        onError: Colors.white,
      );

  static TextTheme _textTheme(TextTheme base, Color onSurface) {
    return TextTheme(
      displaySmall: GoogleFonts.interTight(
        color: onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 28,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.interTight(
        color: onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.interTight(
        color: onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        color: onSurface,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        color: onSurface,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.6,
      ),
      labelLarge: GoogleFonts.inter(
        color: onSurface,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        color: onSurface.withValues(alpha: 0.7),
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 1.4,
      ),
    );
  }
}
