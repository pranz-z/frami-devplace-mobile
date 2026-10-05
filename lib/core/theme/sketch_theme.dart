import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared paper, ink, and marker colors used throughout the workspace.
class SketchPalette {
  static const Color paperLight = Color(0xFFF6F0E7);
  static const Color paperCardLight = Color(0xFFFFFCF5);
  static const Color paperSurfaceLight = Color(0xFFF0E9DE);

  static const Color paperDark = Color(0xFF1C1A18);
  static const Color paperCardDark = Color(0xFF292622);
  static const Color paperSurfaceDark = Color(0xFF34302B);

  static const Color inkDark = Color(0xFF292621);
  static const Color inkMutedLight = Color(0xFF70695F);
  static const Color inkCream = Color(0xFFF3EDE2);
  static const Color inkMutedDark = Color(0xFFB6AEA2);

  static const Color borderLight = Color(0xFF5B554B);
  static const Color borderSubtleLight = Color(0xFFCEC5B8);
  static const Color borderDark = Color(0xFF71685C);
  static const Color borderSubtleDark = Color(0xFF49443D);

  static const Color markerYellow = Color(0xFFF0D76C);
  static const Color markerYellowDark = Color(0xFFC8AC45);
  static const Color sageGreen = Color(0xFF88A882);
  static const Color dustyRose = Color(0xFFD99B91);
  static const Color skyBlue = Color(0xFF8BB3CC);
  static const Color lavender = Color(0xFFB6A2D8);
  static const Color orangePencil = Color(0xFFE2A06B);

  static const Color success = Color(0xFF6E9C68);
  static const Color warning = Color(0xFFD69A3E);
  static const Color danger = Color(0xFFCC6661);
  static const Color info = Color(0xFF5E8BBA);
  static const Color charcoal = Color(0xFF292622);
}

/// Small layout and surface tokens that do not have a Material equivalent.
@immutable
class SketchTokens extends ThemeExtension<SketchTokens> {
  final double space1;
  final double space2;
  final double space3;
  final double space4;
  final double radiusSmall;
  final double radiusCard;
  final double radiusLarge;
  final Color subtleBorder;
  final Color cardShadow;

  const SketchTokens({
    required this.space1,
    required this.space2,
    required this.space3,
    required this.space4,
    required this.radiusSmall,
    required this.radiusCard,
    required this.radiusLarge,
    required this.subtleBorder,
    required this.cardShadow,
  });

  static const light = SketchTokens(
    space1: 4,
    space2: 8,
    space3: 12,
    space4: 16,
    radiusSmall: 6,
    radiusCard: 10,
    radiusLarge: 14,
    subtleBorder: SketchPalette.borderSubtleLight,
    cardShadow: Color(0x225B554B),
  );

  static const dark = SketchTokens(
    space1: 4,
    space2: 8,
    space3: 12,
    space4: 16,
    radiusSmall: 6,
    radiusCard: 10,
    radiusLarge: 14,
    subtleBorder: SketchPalette.borderSubtleDark,
    cardShadow: Color(0x55000000),
  );

  @override
  SketchTokens copyWith({
    double? space1,
    double? space2,
    double? space3,
    double? space4,
    double? radiusSmall,
    double? radiusCard,
    double? radiusLarge,
    Color? subtleBorder,
    Color? cardShadow,
  }) =>
      SketchTokens(
        space1: space1 ?? this.space1,
        space2: space2 ?? this.space2,
        space3: space3 ?? this.space3,
        space4: space4 ?? this.space4,
        radiusSmall: radiusSmall ?? this.radiusSmall,
        radiusCard: radiusCard ?? this.radiusCard,
        radiusLarge: radiusLarge ?? this.radiusLarge,
        subtleBorder: subtleBorder ?? this.subtleBorder,
        cardShadow: cardShadow ?? this.cardShadow,
      );

  @override
  SketchTokens lerp(covariant SketchTokens? other, double t) {
    if (other == null) return this;
    return SketchTokens(
      space1: lerpDouble(space1, other.space1, t)!,
      space2: lerpDouble(space2, other.space2, t)!,
      space3: lerpDouble(space3, other.space3, t)!,
      space4: lerpDouble(space4, other.space4, t)!,
      radiusSmall: lerpDouble(radiusSmall, other.radiusSmall, t)!,
      radiusCard: lerpDouble(radiusCard, other.radiusCard, t)!,
      radiusLarge: lerpDouble(radiusLarge, other.radiusLarge, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

class AppSketchTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background =
        isDark ? SketchPalette.paperDark : SketchPalette.paperLight;
    final card =
        isDark ? SketchPalette.paperCardDark : SketchPalette.paperCardLight;
    final surface = isDark
        ? SketchPalette.paperSurfaceDark
        : SketchPalette.paperSurfaceLight;
    final ink = isDark ? SketchPalette.inkCream : SketchPalette.inkDark;
    final muted =
        isDark ? SketchPalette.inkMutedDark : SketchPalette.inkMutedLight;
    final border =
        isDark ? SketchPalette.borderDark : SketchPalette.borderLight;
    final subtleBorder = isDark
        ? SketchPalette.borderSubtleDark
        : SketchPalette.borderSubtleLight;

    final textTheme = GoogleFonts.caveatTextTheme(
      GoogleFonts.interTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
    ).copyWith(
      headlineLarge: GoogleFonts.caveat(
          fontSize: 34, fontWeight: FontWeight.w700, color: ink, height: 1.08),
      headlineMedium: GoogleFonts.caveat(
          fontSize: 28, fontWeight: FontWeight.w700, color: ink, height: 1.1),
      headlineSmall: GoogleFonts.caveat(
          fontSize: 24, fontWeight: FontWeight.w700, color: ink, height: 1.1),
      titleLarge: GoogleFonts.caveat(
          fontSize: 22, fontWeight: FontWeight.w700, color: ink),
      titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: ink),
      titleSmall: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: ink),
      bodyLarge: GoogleFonts.inter(fontSize: 15, height: 1.45, color: ink),
      bodyMedium: GoogleFonts.inter(fontSize: 13, height: 1.4, color: ink),
      bodySmall: GoogleFonts.inter(fontSize: 11, height: 1.35, color: muted),
      labelLarge: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: ink),
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: SketchPalette.markerYellowDark,
      brightness: brightness,
      primary: isDark ? SketchPalette.markerYellow : SketchPalette.inkDark,
      secondary:
          isDark ? SketchPalette.lavender : SketchPalette.markerYellowDark,
      surface: card,
      error: SketchPalette.danger,
    ).copyWith(
        onSurface: ink,
        onPrimary: isDark ? SketchPalette.inkDark : SketchPalette.paperLight);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: [isDark ? SketchTokens.dark : SketchTokens.light],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.caveat(
            fontSize: 28, fontWeight: FontWeight.w700, color: ink),
        iconTheme: IconThemeData(color: ink),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: subtleBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surface : const Color(0xFFFFFAF1),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.inter(color: muted, fontSize: 13),
        labelStyle: GoogleFonts.inter(color: muted, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: subtleBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: isDark
                  ? SketchPalette.markerYellowDark
                  : SketchPalette.borderLight,
              width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: SketchPalette.inkDark,
          backgroundColor: isDark
              ? SketchPalette.markerYellowDark
              : SketchPalette.markerYellow,
          minimumSize: const Size(48, 46),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: BorderSide(color: border, width: 1),
          ),
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 44),
          side: BorderSide(color: subtleBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          textStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(color: subtleBorder, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: isDark
            ? SketchPalette.markerYellowDark
            : SketchPalette.markerYellow,
        side: BorderSide(color: subtleBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: ink),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: subtleBorder),
        ),
        titleTextStyle: GoogleFonts.caveat(
            fontSize: 24, fontWeight: FontWeight.w700, color: ink),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: ink),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surface : SketchPalette.charcoal,
        contentTextStyle:
            GoogleFonts.inter(color: SketchPalette.inkCream, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor:
            (isDark ? SketchPalette.lavender : SketchPalette.lavender)
                .withValues(alpha: 0.25),
        elevation: 0,
        height: 68,
        labelTextStyle:
            WidgetStateProperty.resolveWith((states) => GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: states.contains(WidgetState.selected) ? ink : muted,
                )),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? SketchPalette.sageGreen
                : null),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
          color: isDark
              ? SketchPalette.markerYellow
              : SketchPalette.markerYellowDark),
    );
  }
}
