import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'paedia_colors.dart';
import 'paedia_tokens.dart';

/// Material 3 theme for Paedia with brand tokens.
abstract final class PaediaTheme {
  /// System stack used on web/iOS before Inter finishes loading.
  static const fontFamilyFallback = [
    '-apple-system',
    'BlinkMacSystemFont',
    'SF Pro Text',
    'SF Pro Display',
    'Segoe UI',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;
    final tokens = isDark ? PaediaTokens.dark : PaediaTokens.light;
    final borderSubtle =
        colorScheme.onSurface.withValues(alpha: isDark ? 0.06 : 0.08);
    final borderFocus = colorScheme.primary.withValues(alpha: 0.55);
    final hoverFill =
        colorScheme.onSurface.withValues(alpha: isDark ? 0.04 : 0.03);
    final interFamily = GoogleFonts.inter().fontFamily;
    final textTheme = _textTheme(colorScheme.onSurface);

    final base = ThemeData(
      useMaterial3: true,
      platform: TargetPlatform.iOS,
      fontFamily: interFamily,
      fontFamilyFallback: fontFamilyFallback,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: [tokens],
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: hoverFill,
      hoverColor: hoverFill,
      visualDensity: VisualDensity.standard,
      typography: Typography.material2021(
        platform: TargetPlatform.iOS,
        colorScheme: colorScheme,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      dividerColor: borderSubtle,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      cardTheme: CardThemeData(
        color: isDark
            ? PaediaColors.surfaceContainerDark
            : PaediaColors.surfaceContainerLight,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderSubtle),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? PaediaColors.surfaceContainerDark
            : PaediaColors.surfaceContainerLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderSubtle),
        ),
        titleTextStyle: GoogleFonts.interTight(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: colorScheme.onSurface.withValues(alpha: 0.85),
          fontSize: 14,
          height: 1.5,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.55),
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: borderSubtle,
        dividerHeight: 1,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        fillColor: isDark
            ? colorScheme.onSurface.withValues(alpha: 0.03)
            : colorScheme.onSurface.withValues(alpha: 0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderFocus, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.error.withValues(alpha: 0.7),
          ),
        ),
        labelStyle: GoogleFonts.inter(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          side: BorderSide(color: borderSubtle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.zero,
        iconColor: colorScheme.onSurface.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(
        color: borderSubtle,
        space: 1,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        height: 64,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.55),
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.55),
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
        linearTrackColor: borderSubtle,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderSubtle),
        ),
      ),
    );
  }

  static ColorScheme get _darkColorScheme => ColorScheme.dark(
        primary: PaediaColors.primary,
        onPrimary: Colors.white,
        secondary: PaediaColors.secondary,
        onSecondary: Colors.white,
        tertiary: PaediaColors.tertiary,
        surface: PaediaColors.surfaceDark,
        onSurface: PaediaColors.onSurfaceDark,
        onSurfaceVariant: PaediaColors.onSurfaceVariantDark,
        surfaceContainerHighest: PaediaColors.surfaceContainerDark,
        surfaceContainerHigh: PaediaColors.surfaceContainerDark,
        surfaceContainer: PaediaColors.surfaceContainerDark,
        error: PaediaColors.error,
        onError: Colors.white,
      );

  static ColorScheme get _lightColorScheme => ColorScheme.light(
        primary: PaediaColors.primary,
        onPrimary: Colors.white,
        secondary: PaediaColors.secondary,
        onSecondary: Colors.white,
        tertiary: PaediaColors.tertiary,
        surface: PaediaColors.surfaceLight,
        onSurface: PaediaColors.onSurfaceLight,
        onSurfaceVariant: PaediaColors.onSurfaceVariantLight,
        surfaceContainerHighest: PaediaColors.surfaceContainerLight,
        surfaceContainerHigh: PaediaColors.surfaceContainerLight,
        surfaceContainer: PaediaColors.surfaceContainerLight,
        error: PaediaColors.error,
        onError: Colors.white,
      );

  static TextTheme _textTheme(Color onSurface) {
    TextStyle inter({
      required double size,
      FontWeight weight = FontWeight.w400,
      double height = 1.5,
      Color? color,
    }) {
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? onSurface,
      );
    }

    TextStyle interTight({
      required double size,
      FontWeight weight = FontWeight.w600,
      double height = 1.35,
      Color? color,
    }) {
      return GoogleFonts.interTight(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? onSurface,
      );
    }

    return TextTheme(
      displaySmall: interTight(size: 28, height: 1.3),
      headlineSmall: interTight(size: 24, height: 1.3),
      titleLarge: interTight(size: 20, height: 1.35),
      titleMedium: interTight(size: 18, height: 1.4),
      titleSmall: interTight(size: 16, height: 1.4),
      bodyLarge: inter(size: 16, height: 1.6),
      bodyMedium: inter(size: 14, height: 1.6),
      bodySmall: inter(
        size: 13,
        height: 1.5,
        color: onSurface.withValues(alpha: 0.65),
      ),
      labelLarge: inter(size: 14, weight: FontWeight.w500, height: 1.4),
      labelSmall: inter(
        size: 12,
        weight: FontWeight.w500,
        height: 1.4,
        color: onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}
