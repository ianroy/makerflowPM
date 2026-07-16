import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../state/providers.dart';
import '../inventory/feature_create_dialogs.dart';
import '../shell/app_shell.dart';

class ConsumablesScreen extends ConsumerWidget {
  const ConsumablesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    return AppShell(
      routePath: '/consumables',
      title: 'Consumables',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showNewConsumableDialog(context);
          if (created != null) ref.invalidate(consumablesProvider);
        },
        tooltip: 'New consumable',
        icon: const Icon(Icons.add),
        label: const Text('New consumable'),
      ),
      child: AsyncList(
        value: ref.watch(consumablesProvider),
        itemBuilder: (context, k) => Semantics(
          button: true,
          label: 'Edit ${k.name}',
          child: InkWell(
            onTap: () async {
              final updated = await showEditConsumableDialog(context, k);
              if (updated != null) ref.invalidate(consumablesProvider);
            },
            borderRadius: BorderRadius.circular(16),
            child: MfCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(k.name, style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
                        Text(
                          '${k.quantityOnHand.toStringAsFixed(0)}${k.unit != null ? ' ${k.unit}' : ''} '
                          '· reorder at ${k.reorderPoint.toStringAsFixed(0)}',
                          style: TextStyle(color: c.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: _statusToken(k.status)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusToken(String s) => switch (s) {
        'inStock' => 'done',
        'low' => 'inProgress',
        'reorder' => 'inProgress',
        'outOfStock' => 'blocked',
        _ => 'todo',
      };
}
