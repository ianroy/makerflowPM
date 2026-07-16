import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../state/providers.dart';
import '../inventory/feature_create_dialogs.dart';
import '../shell/app_shell.dart';

class EquipmentScreen extends ConsumerWidget {
  const EquipmentScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    return AppShell(
      routePath: '/equipment',
      title: 'Equipment',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showNewEquipmentDialog(context);
          if (created != null) ref.invalidate(equipmentProvider);
        },
        tooltip: 'New equipment',
        icon: const Icon(Icons.add),
        label: const Text('New equipment'),
      ),
      child: AsyncList(
        value: ref.watch(equipmentProvider),
        itemBuilder: (context, e) => Semantics(
          button: true,
          label: 'Edit ${e.name}',
          child: InkWell(
            onTap: () async {
              final updated = await showEditEquipmentDialog(context, e);
              if (updated != null) ref.invalidate(equipmentProvider);
            },
            borderRadius: BorderRadius.circular(16),
            child: MfCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name, style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
                        if (e.space != null)
                          Text(e.space!, style: TextStyle(color: c.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  StatusBadge(status: _statusToken(e.status)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusToken(String s) => switch (s) {
        'operational' => 'done',
        'maintenanceDue' => 'inProgress',
        'underMaintenance' => 'inProgress',
        'outOfService' => 'blocked',
        'retired' => 'backlog',
        _ => 'todo',
      };
}
