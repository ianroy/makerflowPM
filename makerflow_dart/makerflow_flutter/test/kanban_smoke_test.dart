import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/features/tasks/kanban_screen.dart';

// Smoke test: the kanban renders its columns and the seeded tasks from the
// in-memory repository. Expands as the vertical slice grows.
void main() {
  testWidgets('Kanban renders columns and a seeded task', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MakerflowThemeBuilder.dark(),
          home: const KanbanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Unique seeded task titles prove the board hydrated from the repository.
    expect(find.text('Laser cutter monthly PM'), findsOneWidget);
    expect(find.text('Onboard fall student cohort'), findsOneWidget);
    // Column labels also appear on status badges, so there can be >1 — assert
    // the board rendered its columns without pinning an exact count.
    expect(find.text('In progress'), findsWidgets);
    expect(find.text('Done'), findsWidgets);
  });
}
