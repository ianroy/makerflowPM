import 'package:flutter/material.dart';
import 'tokens.dart';

/// A [ThemeExtension] carrying the MakerFlow tokens that don't map cleanly to
/// Material's [ColorScheme] (card-soft, line, focus, the offset shadow).
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

/// Builds Material 3 [ThemeData] from the token set. Avenir Next is bundled in
/// the app (pubspec fonts); falls back to the platform sans-serif.
class MakerflowThemeBuilder {
  static ThemeData _build(MakerflowColors c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.brand,
      brightness: brightness,
    ).copyWith(
      surface: c.card,
      onSurface: c.text,
      primary: c.brand,
      secondary: c.brand2,
      error: c.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      fontFamily: 'AvenirNext',
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MakerflowShape.radiusCard),
          side: BorderSide(color: c.line),
        ),
      ),
      // Visible focus ring everywhere (WCAG 2.4.7 / 1.4.11) — never stripped.
      focusColor: c.focus,
      extensions: [MakerflowTheme(colors: c)],
    );
  }

  static ThemeData dark() =>
      _build(MakerflowColors.dark, Brightness.dark);
  static ThemeData light() =>
      _build(MakerflowColors.light, Brightness.light);
}
