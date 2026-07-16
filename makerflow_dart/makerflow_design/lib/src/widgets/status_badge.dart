import 'package:flutter/material.dart';
import '../tokens.dart';

/// Status indicator, monday-style: a solid label-colored pill (radius 4) with
/// the status TEXT inside it — the text is the non-color cue (WCAG 1.4.1) and
/// a small icon adds redundancy. Text color is AA-picked per label
/// ([MndLabelColors.textOn], WCAG 1.4.3).
///
/// `semanticLabel` ensures screen readers announce the status (1.1.1).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  /// A normalized status token, e.g. 'todo', 'inProgress', 'done', 'blocked'.
  final String status;

  static const icons = <String, IconData>{
    'backlog': Icons.circle_outlined,
    'todo': Icons.radio_button_unchecked,
    'inProgress': Icons.timelapse,
    'inReview': Icons.rate_review_outlined,
    'blocked': Icons.block,
    'done': Icons.check_circle_outline,
  };

  static const labels = <String, String>{
    'backlog': 'Backlog',
    'todo': 'To do',
    'inProgress': 'In progress',
    'inReview': 'In review',
    'blocked': 'Blocked',
    'done': 'Done',
  };

  @override
  Widget build(BuildContext context) {
    final icon = icons[status] ?? Icons.help_outline;
    final label = labels[status] ?? status;
    final bg = MndLabelColors.status[status] ?? MndLabelColors.blank;
    final fg = MndLabelColors.textOn(bg);

    return Semantics(
      label: 'Status: $label',
      excludeSemantics: true, // announce once, not label + inner text
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: MndSpace.s8, vertical: MndSpace.s4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(MakerflowShape.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: MndSpace.s4),
            Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
          ],
        ),
      ),
    );
  }
}
