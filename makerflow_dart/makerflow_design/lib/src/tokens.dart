import 'package:flutter/widgets.dart';

/// Color tokens ported 1:1 from the legacy `app/static/style.css` `:root`
/// blocks (ProductSpec.md §12). Two themes; reference tokens, never hard-code.
@immutable
class MakerflowColors {
  const MakerflowColors({
    required this.bg,
    required this.bgAccent,
    required this.card,
    required this.cardSoft,
    required this.text,
    required this.muted,
    required this.line,
    required this.brand,
    required this.brand2,
    required this.focus,
    required this.danger,
    required this.shadow,
  });

  final Color bg;
  final Color bgAccent;
  final Color card;
  final Color cardSoft;
  final Color text;
  final Color muted;
  final Color line;
  final Color brand;
  final Color brand2;
  final Color focus;
  final Color danger;
  final Color shadow;

  /// Dark theme (the product default).
  static const dark = MakerflowColors(
    bg: Color(0xFF0D1420),
    bgAccent: Color(0xFF122231),
    card: Color(0xFF162332),
    cardSoft: Color(0xFF1D2D42),
    text: Color(0xFFF2F8FF),
    muted: Color(0xFFD2DEEE),
    line: Color(0xFF4B617A),
    brand: Color(0xFF8FD5FF),
    brand2: Color(0xFF2FD0A8),
    focus: Color(0xFFFFB454),
    danger: Color(0xFFFF7893),
    shadow: Color(0xFF101A27),
  );

  /// Light theme.
  static const light = MakerflowColors(
    bg: Color(0xFFF3F7FF),
    bgAccent: Color(0xFFFFF1DF),
    card: Color(0xFFFFFFFF),
    cardSoft: Color(0xFFF7FBFF),
    text: Color(0xFF1B2330),
    muted: Color(0xFF506079),
    line: Color(0xFFD7DFEB),
    brand: Color(0xFF0B7BD9),
    brand2: Color(0xFF00A882),
    focus: Color(0xFFFF8F00),
    danger: Color(0xFFD7263D),
    shadow: Color(0xFFE9F0FA),
  );
}

/// Shape + spacing tokens (ProductSpec.md §12.3).
class MakerflowShape {
  static const radiusSmall = 8.0;
  static const radiusControl = 10.0;
  static const radiusNotice = 12.0;
  static const radiusCard = 16.0;
  static const radiusPill = 999.0;

  /// The signature flat, offset, no-blur card shadow (`0 3px 0 shadow`).
  static List<BoxShadow> cardShadow(Color shadow) =>
      [BoxShadow(color: shadow, offset: const Offset(0, 3), blurRadius: 0)];
}
