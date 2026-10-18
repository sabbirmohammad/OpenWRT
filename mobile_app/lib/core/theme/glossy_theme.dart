import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glossy_colors.dart';

class GlossyTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GlossyColors.backgroundPrimary,
      primaryColor: GlossyColors.primaryBlue,
      canvasColor: GlossyColors.backgroundSecondary,
      colorScheme: const ColorScheme.dark(
        primary: GlossyColors.primaryBlue,
        secondary: GlossyColors.lightBlue,
        surface: GlossyColors.backgroundSecondary,
        error: GlossyColors.roseCoral,
        onPrimary: GlossyColors.textPrimary,
        onSecondary: GlossyColors.textPrimary,
        onSurface: GlossyColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: GlossyColors.backgroundPrimary,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: GlossyColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: GlossyColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          color: GlossyColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        titleMedium: TextStyle(
          color: GlossyColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          color: GlossyColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.1,
        ),
        bodyMedium: TextStyle(
          color: GlossyColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          color: GlossyColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: GlossyColors.glassDivider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
