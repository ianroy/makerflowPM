import 'package:flutter/material.dart';
import '../tokens.dart';

/// monday-style status label. Two modes:
/// - [StatusLabel.cell]: full-bleed colored rectangle (the Main Table cell)
/// - [StatusLabel.pill]: compact radius-4 pill (cards, lists)
/// Text is AA-picked per label color; the text itself is the non-color cue.
class StatusLabel extends StatelessWidget {
  const StatusLabel.cell({super.key, required this.status, this.onTap})
      : _cell = true;
  const StatusLabel.pill({super.key, required this.status, this.onTap})
      : _cell = false;

  /// Normalized status token ('todo', 'inProgress', …).
  final String status;
  final VoidCallback? onTap;
  final bool _cell;

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
    final bg = MndLabelColors.status[status] ?? MndLabelColors.blank;
    final fg = MndLabelColors.textOn(bg);
    final label = labels[status] ?? status;

    final child = Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(minHeight: _cell ? 32 : 24),
      padding: EdgeInsets.symmetric(horizontal: _cell ? MndSpace.s8 : MndSpace.s12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: _cell ? BorderRadius.zero : BorderRadius.circular(MakerflowShape.radiusSmall),
      ),
      child: ExcludeSemantics(
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
      ),
    );

    if (onTap == null) return Semantics(label: 'Status: $label', child: child);
    return Semantics(
      button: true,
      label: 'Status: $label. Change status',
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

/// The monday label-picker: full-width colored buttons, one per status.
/// Returns the picked status token, or null if dismissed.
Future<String?> showStatusPicker(BuildContext context, {String? current}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MakerflowShape.radiusNotice)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Padding(
          padding: const EdgeInsets.all(MndSpace.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in StatusLabel.labels.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: MndSpace.s2),
                  child: SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      button: true,
                      selected: entry.key == current,
                      child: InkWell(
                        onTap: () => Navigator.of(ctx).pop(entry.key),
                        borderRadius: BorderRadius.circular(MakerflowShape.radiusSmall),
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: MndLabelColors.status[entry.key],
                            borderRadius: BorderRadius.circular(MakerflowShape.radiusSmall),
                          ),
                          child: Text(entry.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: MndLabelColors.textOn(MndLabelColors.status[entry.key]!),
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
