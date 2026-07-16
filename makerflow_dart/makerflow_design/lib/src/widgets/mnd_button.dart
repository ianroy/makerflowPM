import 'package:flutter/material.dart';
import '../theme.dart';
import '../tokens.dart';

enum MndButtonKind { primary, secondary, tertiary }

enum MndButtonSize { small, medium, large }

/// Vibe-style button: 3 kinds × 3 sizes, radius 4, press-scale 0.95 @70ms.
class MndButton extends StatefulWidget {
  const MndButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = MndButtonKind.primary,
    this.size = MndButtonSize.medium,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final MndButtonKind kind;
  final MndButtonSize size;
  final IconData? icon;

  @override
  State<MndButton> createState() => _MndButtonState();
}

class _MndButtonState extends State<MndButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    final height = switch (widget.size) {
      MndButtonSize.small => 32.0,
      MndButtonSize.medium => 40.0,
      MndButtonSize.large => 48.0,
    };
    final child = widget.icon == null
        ? Text(widget.label)
        : Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, size: 18),
            const SizedBox(width: MndSpace.s8),
            Text(widget.label),
          ]);

    final button = switch (widget.kind) {
      MndButtonKind.primary => FilledButton(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(minimumSize: Size(64, height)),
          child: child),
      MndButtonKind.secondary => OutlinedButton(
          onPressed: widget.onPressed,
          style: OutlinedButton.styleFrom(minimumSize: Size(64, height), side: BorderSide(color: c.borderControl)),
          child: child),
      MndButtonKind.tertiary => TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(minimumSize: Size(48, height)),
          child: child),
    };

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed && widget.onPressed != null ? 0.95 : 1,
        duration: MndMotion.productiveShort,
        child: button,
      ),
    );
  }
}
