import 'package:flutter/material.dart';
import '../tokens.dart';

/// monday-style toast: floating snack with an optional Undo action.
void showMndToast(BuildContext context, String message, {VoidCallback? onUndo}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 5),
    action: onUndo == null
        ? null
        : SnackBarAction(label: 'Undo', textColor: const Color(0xFF69A7EF), onPressed: onUndo),
  ));
}

/// Friendly empty state: icon, headline, optional body + primary CTA.
class MndEmptyState extends StatelessWidget {
  const MndEmptyState({
    super.key,
    required this.icon,
    required this.headline,
    this.body,
    this.ctaLabel,
    this.onCta,
  });

  final IconData icon;
  final String headline;
  final String? body;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MndSpace.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: MndSpace.s16),
            Text(headline, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: MndSpace.s8),
              Text(body!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
            if (ctaLabel != null) ...[
              const SizedBox(height: MndSpace.s16),
              FilledButton(onPressed: onCta, child: Text(ctaLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
