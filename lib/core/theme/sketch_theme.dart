import 'package:flutter/material.dart';

/// Hand-drawn sketchbook color palette
class SketchPalette {
  // Light mode background: Warm parchment / sketchbook paper
  static const Color paperLight = Color(0xFFFBF6EA);
  static const Color paperCardLight = Color(0xFFFFFDF8);
  static const Color paperSurfaceLight = Color(0xFFF3ECE0);

  // Dark mode background: Warm near-black charcoal
  static const Color paperDark = Color(0xFF1C1A17);
  static const Color paperCardDark = Color(0xFF26231E);
  static const Color paperSurfaceDark = Color(0xFF302C26);

  // Ink colors
  static const Color inkDark = Color(0xFF2B2823);
  static const Color inkMutedLight = Color(0xFF6B655B);
  static const Color inkCream = Color(0xFFEDE6D8);
  static const Color inkMutedDark = Color(0xFFA59E92);

  // Sketch borders
  static const Color borderLight = Color(0xFF3A352E);
  static const Color borderSubtleLight = Color(0xFFB5ADA0);
  static const Color borderDark = Color(0xFF5A5348);
  static const Color borderSubtleDark = Color(0xFF3F3A32);

  // Muted sketchbook accents
  static const Color markerYellow = Color(0xFFF5DE6B);
  static const Color markerYellowDark = Color(0xFFC9B036);
  static const Color sageGreen = Color(0xFF88A882);
  static const Color dustyRose = Color(0xFFDA8A83);
  static const Color skyBlue = Color(0xFF7FA9C7);
  static const Color lavender = Color(0xFFA497C4);
  static const Color orangePencil = Color(0xFFE29A5C);

  // Status colors
  static const Color success = Color(0xFF6E9C68);
  static const Color warning = Color(0xFFD69A3E);
  static const Color danger = Color(0xFFCC5E5E);
  static const Color info = Color(0xFF5E8BBA);
}

class AppSketchTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: SketchPalette.paperLight,
      colorScheme: const ColorScheme.light(
        primary: SketchPalette.borderLight,
        secondary: SketchPalette.markerYellowDark,
        surface: SketchPalette.paperCardLight,
        error: SketchPalette.danger,
        onPrimary: SketchPalette.paperLight,
        onSecondary: SketchPalette.inkDark,
        onSurface: SketchPalette.inkDark,
        onError: Colors.white,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Caveat',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: SketchPalette.inkDark,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Caveat',
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: SketchPalette.inkDark,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Caveat',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: SketchPalette.inkDark,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Caveat',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: SketchPalette.inkDark,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: SketchPalette.inkDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: SketchPalette.inkDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: SketchPalette.inkDark,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          color: SketchPalette.inkMutedLight,
        ),
      ),
      cardTheme: const CardThemeData(
        color: SketchPalette.paperCardLight,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SketchPalette.paperLight,
        foregroundColor: SketchPalette.inkDark,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SketchPalette.paperCardLight,
        selectedItemColor: SketchPalette.inkDark,
        unselectedItemColor: SketchPalette.inkMutedLight,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SketchPalette.paperDark,
      colorScheme: const ColorScheme.dark(
        primary: SketchPalette.inkCream,
        secondary: SketchPalette.markerYellow,
        surface: SketchPalette.paperCardDark,
        error: SketchPalette.danger,
        onPrimary: SketchPalette.paperDark,
        onSecondary: SketchPalette.inkDark,
        onSurface: SketchPalette.inkCream,
        onError: Colors.white,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Caveat',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: SketchPalette.inkCream,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Caveat',
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: SketchPalette.inkCream,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Caveat',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: SketchPalette.inkCream,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Caveat',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: SketchPalette.inkCream,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: SketchPalette.inkCream,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: SketchPalette.inkCream,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: SketchPalette.inkCream,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          color: SketchPalette.inkMutedDark,
        ),
      ),
      cardTheme: const CardThemeData(
        color: SketchPalette.paperCardDark,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SketchPalette.paperDark,
        foregroundColor: SketchPalette.inkCream,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SketchPalette.paperCardDark,
        selectedItemColor: SketchPalette.inkCream,
        unselectedItemColor: SketchPalette.inkMutedDark,
        elevation: 8,
      ),
    );
  }
}
