import 'package:flutter/widgets.dart';

/// Design tokens for the monday.com-style redesign (UI-0), sourced from
/// monday's open-source **Vibe** design system (github.com/mondaycom/vibe —
/// exact values; see ../../UI_REDESIGN_PLAN.md §2.2).
///
/// [MakerflowColors] keeps its original field names so every existing screen
/// compiles unchanged — the VALUES are now Vibe's. New surfaces/tokens are
/// additive fields + the Mnd* constant classes below.
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
    required this.frame,
    required this.canvas,
    required this.hover,
    required this.selected,
    required this.highlight,
    required this.link,
    required this.positive,
    required this.warning,
    required this.borderControl,
    required this.disabledBg,
  });

  // --- legacy-named fields (values are now Vibe's) ---
  final Color bg; // content sheet background (white / dark navy)
  final Color bgAccent; // soft grey panel (kanban columns, wells)
  final Color card; // card surface
  final Color cardSoft; // hover-ish soft surface
  final Color text; // primary text
  final Color muted; // secondary text + icons
  final Color line; // layout/grid border
  final Color brand; // primary action blue
  final Color brand2; // done green (positive accent)
  final Color focus; // keyboard-focus ring base
  final Color danger; // negative
  final Color shadow; // card shadow color

  // --- new Vibe surfaces/tokens ---
  final Color frame; // app frame behind the content sheet
  final Color canvas; // grey canvas (dashboards, wells)
  final Color hover; // hover tint on white
  final Color selected; // selected row/tab fill
  final Color highlight; // highlighted/selected-subtle fill
  final Color link;
  final Color positive; // semantic positive (text-safe)
  final Color warning;
  final Color borderControl; // input/control border
  final Color disabledBg;

  /// Light theme — the product default (monday is light-first).
  static const light = MakerflowColors(
    bg: Color(0xFFFFFFFF),
    bgAccent: Color(0xFFF6F7FB),
    card: Color(0xFFFFFFFF),
    cardSoft: Color(0xFFF6F7FB),
    text: Color(0xFF323338),
    muted: Color(0xFF676879),
    line: Color(0xFFD0D4E4),
    brand: Color(0xFF0073EA),
    brand2: Color(0xFF00C875),
    focus: Color(0xFF0073EA),
    danger: Color(0xFFD83A52),
    shadow: Color(0x1A000000),
    frame: Color(0xFFECEFF8),
    canvas: Color(0xFFF6F7FB),
    hover: Color(0x1A676879),
    selected: Color(0xFFCCE5FF),
    highlight: Color(0xFFF0F7FF),
    link: Color(0xFF1F76C2),
    positive: Color(0xFF00854D),
    warning: Color(0xFFFFCB00),
    borderControl: Color(0xFFC3C6D4),
    disabledBg: Color(0xFFECEDF5),
  );

  /// Dark theme (Vibe dark: navy family, same brand blue).
  static const dark = MakerflowColors(
    bg: Color(0xFF181B34),
    bgAccent: Color(0xFF30324E),
    card: Color(0xFF30324E),
    cardSoft: Color(0xFF3B3D5C),
    text: Color(0xFFD5D8DF),
    muted: Color(0xFF9699A6),
    line: Color(0xFF4B4E69),
    brand: Color(0xFF0073EA),
    brand2: Color(0xFF00C875),
    focus: Color(0xFF69A7EF),
    danger: Color(0xFFD83A52),
    shadow: Color(0x80090B19),
    frame: Color(0xFF111427),
    canvas: Color(0xFF232743),
    hover: Color(0x33797E93),
    selected: Color(0xFF1F3A5F),
    highlight: Color(0xFF23345C),
    link: Color(0xFF69A7EF),
    positive: Color(0xFF33D391),
    warning: Color(0xFFFFCB00),
    borderControl: Color(0xFF797E93),
    disabledBg: Color(0xFF3B3D5C),
  );
}

/// Shape tokens. Field names kept for compat; values are Vibe's
/// (4 controls/cells · 8 cards/popovers · 16 modals/widgets).
class MakerflowShape {
  static const radiusSmall = 4.0;
  static const radiusControl = 4.0;
  static const radiusNotice = 8.0;
  static const radiusCard = 8.0;
  static const radiusModal = 16.0;
  static const radiusPill = 999.0; // avatars/toggles only; label pills use 4

  /// Vibe shadow-xs — the resting card shadow.
  static List<BoxShadow> cardShadow(Color shadow) => [
        BoxShadow(color: shadow, offset: const Offset(0, 4), blurRadius: 6, spreadRadius: -4),
      ];
}

/// Vibe elevation set (light theme values).
class MndShadows {
  static const xs = [BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -4)];
  static const small = [BoxShadow(color: Color(0x33000000), offset: Offset(0, 4), blurRadius: 8)];
  static const medium = [BoxShadow(color: Color(0x33000000), offset: Offset(0, 6), blurRadius: 20)]; // popovers
  static const large = [BoxShadow(color: Color(0x4D000000), offset: Offset(0, 15), blurRadius: 50)]; // modals
}

/// Vibe spacing scale (compose paddings only from these).
class MndSpace {
  static const s2 = 2.0, s4 = 4.0, s8 = 8.0, s12 = 12.0, s16 = 16.0, s20 = 20.0,
      s24 = 24.0, s32 = 32.0, s40 = 40.0, s48 = 48.0, s64 = 64.0, s80 = 80.0;
}

/// Vibe motion tokens.
class MndMotion {
  static const productiveShort = Duration(milliseconds: 70);
  static const productive = Duration(milliseconds: 100);
  static const productiveLong = Duration(milliseconds: 150);
  static const expressive = Duration(milliseconds: 250);
  static const expressiveLong = Duration(milliseconds: 400);
  static const enter = Cubic(0, 0, 0.35, 1);
  static const exit = Cubic(0.4, 0, 1, 1);
  static const transition = Cubic(0.4, 0, 0.2, 1);
  static const emphasize = Cubic(0, 0, 0.2, 1.4); // the popover "pop"
}

/// The Vibe content/label palette — status labels + group colors.
/// Names follow Vibe's (subset of the 40 covering our status set + groups;
/// extend when custom-label editing lands).
class MndLabelColors {
  static const grassGreen = Color(0xFF037F4C);
  static const done = Color(0xFF00C875); // done-green
  static const brightGreen = Color(0xFF9CD326);
  static const eggYolk = Color(0xFFFFCB00);
  static const working = Color(0xFFFDAB3D); // working-orange
  static const darkOrange = Color(0xFFFF6D3B);
  static const sunset = Color(0xFFFF7575);
  static const stuck = Color(0xFFDF2F4A); // stuck-red (AA-revised)
  static const stuckLegacy = Color(0xFFE2445C);
  static const darkRed = Color(0xFFBB3354);
  static const sofiaPink = Color(0xFFE50073);
  static const lipstick = Color(0xFFFF5AC4);
  static const purple = Color(0xFF9D50DD);
  static const darkPurple = Color(0xFF784BD1);
  static const berry = Color(0xFF7E3B8A);
  static const indigo = Color(0xFF5559DF);
  static const navy = Color(0xFF225091);
  static const brightBlue = Color(0xFF579BFC);
  static const darkBlue = Color(0xFF007EB5);
  static const aquamarine = Color(0xFF4ECCC6);
  static const chiliBlue = Color(0xFF66CCFF);
  static const river = Color(0xFF74AFCC);
  static const winter = Color(0xFF9AADBD);
  static const blank = Color(0xFFC4C4C4); // "explosive" — the empty label
  static const americanGray = Color(0xFF757575);
  static const blackish = Color(0xFF333333);
  static const brown = Color(0xFF7F5347);
  static const royal = Color(0xFF216EDF);
  static const teal = Color(0xFF175A63);
  static const lavender = Color(0xFFBDA8F9);

  /// The picker grid, in monday's rough order.
  static const grid = <Color>[
    grassGreen, done, brightGreen, eggYolk, working, darkOrange, sunset, stuck,
    darkRed, sofiaPink, lipstick, purple, darkPurple, berry, indigo, navy,
    brightBlue, darkBlue, aquamarine, chiliBlue, river, winter, blank,
    americanGray, blackish, brown, royal, teal, lavender,
  ];

  /// Our fixed TaskStatus → label color map (monday defaults where they map;
  /// custom labels via FieldConfig come later — UI_REDESIGN_PLAN §3).
  static const status = <String, Color>{
    'backlog': brightBlue, // black ink (AA 7.5:1)
    'todo': americanGray, // white text (AA 4.6:1); not blank-gray (fails AA)
    'inProgress': working, // black ink (AA 11:1)
    'inReview': darkPurple, // white text (AA 5.6:1)
    'blocked': darkRed, // white text (AA 5.7:1) — stuck-red itself is 4.49, just under AA
    'done': done, // black ink (AA 9.5:1)
  };

  /// Group colors for board groups (deterministic pick by index).
  static const groups = <Color>[done, brightBlue, purple, working, indigo, aquamarine, lipstick, darkOrange];

  /// AA-safe text color for a label background: black ink on bright labels,
  /// white on dark labels (WCAG 1.4.3 — monday's white-on-everything fails on
  /// its brightest labels; our mandate wins over pixel-fidelity there).
  /// Threshold verified by the design-system contrast test.
  static Color textOn(Color bg) =>
      bg.computeLuminance() > 0.3 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
}
