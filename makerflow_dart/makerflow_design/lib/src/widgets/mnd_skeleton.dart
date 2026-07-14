import 'package:flutter/material.dart';
import '../theme.dart';
import '../tokens.dart';

/// Vibe skeleton: a grey block that pulses OPACITY 0.4→1 (0.8s, alternate) —
/// monday pulses opacity rather than sweeping a shimmer.
class MndSkeleton extends StatefulWidget {
  const MndSkeleton({super.key, this.width, this.height = 16, this.circle = false});

  final double? width;
  final double height;
  final bool circle;

  @override
  State<MndSkeleton> createState() => _MndSkeletonState();
}

class _MndSkeletonState extends State<MndSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
    lowerBound: 0.4,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = MakerflowTheme.of(context).colors;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final block = Container(
      width: widget.width ?? (widget.circle ? widget.height : double.infinity),
      height: widget.height,
      decoration: BoxDecoration(
        color: colors.disabledBg,
        shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: widget.circle ? null : BorderRadius.circular(MakerflowShape.radiusSmall),
      ),
    );
    if (reduce) return block;
    return FadeTransition(opacity: _c, child: block);
  }
}
