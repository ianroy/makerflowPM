import 'package:flutter/material.dart';
import '../theme.dart';
import '../tokens.dart';

/// The canonical surface: 16px radius, 1px line border, flat offset shadow.
/// Mirrors the legacy `.card` rule.
class MfCard extends StatelessWidget {
  const MfCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    final card = Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(MakerflowShape.radiusCard),
        border: Border.all(color: c.line),
        boxShadow: MakerflowShape.cardShadow(c.shadow),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MakerflowShape.radiusCard),
      child: card,
    );
  }
}
