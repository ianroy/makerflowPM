import 'package:flutter/material.dart';
import '../theme.dart';

/// Status indicator that carries a NON-COLOR cue (icon + label), not color
/// alone — WCAG 1.4.1 (Use of Color) and 1.3.3. This is the single source for
/// the status icon↔meaning map referenced across the app.
///
/// `semanticLabel` ensures screen readers announce the status text (1.1.1).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  /// A normalized status token, e.g. 'todo', 'inProgress', 'done', 'blocked'.
  final String status;

  static const _icons = <String, IconData>{
    'backlog': Icons.circle_outlined,
    'todo': Icons.radio_button_unchecked,
    'inProgress': Icons.timelapse,
    'inReview': Icons.rate_review_outlined,
    'blocked': Icons.block,
    'done': Icons.check_circle,
  };

  static const _labels = <String, String>{
    'backlog': 'Backlog',
    'todo': 'To do',
    'inProgress': 'In progress',
    'inReview': 'In review',
    'blocked': 'Blocked',
    'done': 'Done',
  };

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    final icon = _icons[status] ?? Icons.help_outline;
    final label = _labels[status] ?? status;
    // Color is supplementary only; the icon + label carry the meaning.
    final accent = switch (status) {
      'done' => c.brand2,
      'blocked' => c.danger,
      'inProgress' || 'inReview' => c.focus,
      _ => c.muted,
    };

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: c.cardSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accent),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: c.text)),
          ],
        ),
      ),
    );
  }
}
