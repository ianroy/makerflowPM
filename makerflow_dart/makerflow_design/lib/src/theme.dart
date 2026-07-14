import 'package:flutter/material.dart';
import 'tokens.dart';

/// A [ThemeExtension] carrying the full token set (surfaces, borders, labels
/// — everything Material's [ColorScheme] can't express).
@immutable
class MakerflowTheme extends ThemeExtension<MakerflowTheme> {
  const MakerflowTheme({required this.colors});
  final MakerflowColors colors;

  @override
  MakerflowTheme copyWith({MakerflowColors? colors}) =>
      MakerflowTheme(colors: colors ?? this.colors);

  @override
  MakerflowTheme lerp(ThemeExtension<MakerflowTheme>? other, double t) => this;

  static MakerflowTheme of(BuildContext context) =>
      Theme.of(context).extension<MakerflowTheme>()!;
}

/// Bundled font families (declared in this package's pubspec; the
/// `packages/` prefix lets any app depending on makerflow_design use them).
class MndFonts {
  static const body = 'packages/makerflow_design/Figtree';
  static const title = 'packages/makerflow_design/Poppins';
}

/// Builds Material 3 [ThemeData] from the Vibe-derived token set.
/// Light is the product default (monday is light-first); dark uses Vibe dark.
class MakerflowThemeBuilder {
  static ThemeData _build(MakerflowColors c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.brand,
      brightness: brightness,
    ).copyWith(
      surface: c.card,
      onSurface: c.text,
      primary: c.brand,
      onPrimary: Colors.white,
      secondary: c.brand2,
      error: c.danger,
      outline: c.borderControl,
      outlineVariant: c.line,
    );

    // Vibe type scale: Figtree text1 16/22 · text2 14/20 (default) · text3
    // 12/16; Poppins for H1–H3 titles.
    final textTheme = TextTheme(
      headlineLarge: TextStyle(fontFamily: MndFonts.title, fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: c.text),
      headlineMedium: TextStyle(fontFamily: MndFonts.title, fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w600, letterSpacing: -0.1, color: c.text),
      headlineSmall: TextStyle(fontFamily: MndFonts.title, fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600, letterSpacing: -0.1, color: c.text),
      titleLarge: TextStyle(fontFamily: MndFonts.title, fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600, color: c.text),
      titleMedium: TextStyle(fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w600, color: c.text),
      titleSmall: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: c.text),
      bodyLarge: TextStyle(fontSize: 16, height: 22 / 16, color: c.text),
      bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, color: c.text),
      bodySmall: TextStyle(fontSize: 12, height: 16 / 12, color: c.muted),
      labelLarge: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: c.text),
      labelMedium: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: c.muted),
      labelSmall: TextStyle(fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w500, color: c.muted),
    );

    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(MakerflowShape.radiusControl),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      fontFamily: MndFonts.body,
      textTheme: textTheme,
      dividerColor: c.line,
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: IconThemeData(color: c.muted, size: 20),
      ),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MakerflowShape.radiusCard),
          side: BorderSide(color: c.line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MakerflowShape.radiusModal)),
        titleTextStyle: textTheme.headlineSmall,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MakerflowShape.radiusNotice)),
        elevation: 6,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 40),
          padding: const EdgeInsets.symmetric(horizontal: MndSpace.s16),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.hovered) || s.contains(WidgetState.pressed)
                  ? const Color(0xFF0060B9)
                  : null),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 40),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          side: BorderSide(color: c.borderControl),
          minimumSize: const Size(64, 40),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.text,
          minimumSize: const Size(48, 32),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.brand,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MakerflowShape.radiusCard)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: MndSpace.s12, vertical: MndSpace.s12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MakerflowShape.radiusControl),
          borderSide: BorderSide(color: c.borderControl),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MakerflowShape.radiusControl),
          borderSide: BorderSide(color: c.borderControl),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MakerflowShape.radiusControl),
          borderSide: BorderSide(color: c.brand, width: 2),
        ),
        labelStyle: TextStyle(color: c.muted, fontSize: 14),
        hintStyle: TextStyle(color: c.muted, fontSize: 14),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: c.selected,
          selectedForegroundColor: c.text,
          foregroundColor: c.muted,
          side: BorderSide(color: c.borderControl),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light ? const Color(0xFF323338) : c.cardSoft,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: MndFonts.body),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MakerflowShape.radiusNotice)),
      ),
      // Visible keyboard focus everywhere (WCAG 2.4.7) — Vibe's azure ring.
      focusColor: c.focus.withValues(alpha: 0.5),
      hoverColor: c.hover,
      extensions: [MakerflowTheme(colors: c)],
    );
  }

  static ThemeData light() => _build(MakerflowColors.light, Brightness.light);
  static ThemeData dark() => _build(MakerflowColors.dark, Brightness.dark);
}
