import 'package:flutter/material.dart';
import '../tokens.dart';

/// Circular avatar with initials on a deterministic label-palette color.
class MndAvatar extends StatelessWidget {
  const MndAvatar({super.key, required this.name, this.size = 28});

  final String name;
  final double size;

  static Color colorFor(String name) =>
      MndLabelColors.groups[name.hashCode.abs() % MndLabelColors.groups.length];

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = colorFor(name);
    return Semantics(
      label: name,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Text(initialsOf(name),
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.w600,
              color: MndLabelColors.textOn(bg),
            )),
      ),
    );
  }
}

/// Overlapping avatar stack with a "+N" overflow chip.
class MndAvatarStack extends StatelessWidget {
  const MndAvatarStack({super.key, required this.names, this.max = 3, this.size = 28});

  final List<String> names;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    final shown = names.take(max).toList();
    final overflow = names.length - shown.length;
    return Semantics(
      label: names.join(', '),
      child: SizedBox(
        height: size,
        width: shown.isEmpty
            ? size
            : size + (shown.length - 1 + (overflow > 0 ? 1 : 0)) * size * 0.7,
        child: Stack(
          children: [
            for (var i = 0; i < shown.length; i++)
              Positioned(left: i * size * 0.7, child: MndAvatar(name: shown[i], size: size)),
            if (overflow > 0)
              Positioned(
                left: shown.length * size * 0.7,
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0xFFE7E9EF), shape: BoxShape.circle),
                  child: Text('+$overflow',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF323338))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
