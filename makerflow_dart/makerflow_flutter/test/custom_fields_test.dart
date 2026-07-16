import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/data/field_models.dart';
import 'package:makerflow_flutter/src/data/field_repository.dart';
import 'package:makerflow_flutter/src/features/tasks/kanban_screen.dart';
import 'package:makerflow_flutter/src/state/providers.dart';

/// fl-8-custom-fields: definitions become table columns; per-type cells
/// render and edit values; the Columns popover manages definitions.
Future<InMemoryFieldRepository> _seededFields() async {
  final repo = InMemoryFieldRepository();
  await repo.save(
      1, const FieldConfigVm(key: 'material', label: 'Material', fieldType: 'label', options: [
    FieldOption('Wood', color: MndLabelColors.brown),
    FieldOption('Metal', color: MndLabelColors.winter),
  ]));
  await repo.save(1,
      const FieldConfigVm(key: 'weight_kg', label: 'Weight', fieldType: 'number'));
  await repo.save(1,
      const FieldConfigVm(key: 'approved', label: 'Approved', fieldType: 'checkbox'));
  return repo;
}

Future<ProviderContainer> _pump(WidgetTester tester,
    {required FieldRepository fields}) async {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [fieldRepositoryProvider.overrideWithValue(fields)],
      child: MaterialApp(
          theme: MakerflowThemeBuilder.light(), home: const KanbanScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(KanbanScreen)));
}

Future<void> _flushSave(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 600));

Future<void> _openPopover(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('board-columns'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('field definitions render as table columns', (tester) async {
    await _pump(tester, fields: await _seededFields());
    expect(find.text('Material'), findsNWidgets(6)); // one header per group
    expect(find.text('Weight'), findsNWidgets(6));
    expect(find.text('Approved'), findsNWidgets(6));
  });

  testWidgets('label cell opens the option picker and persists the value',
      (tester) async {
    final container = await _pump(tester, fields: await _seededFields());

    // Every label cell is empty (—) at start; several columns show dashes, so
    // scope the tap to the first row's Material cell via its semantics label.
    await tester.tap(
        find.bySemanticsLabel(RegExp(r'^Material: —, for Restock 3mm plywood')));
    await tester.pumpAndSettle();
    expect(find.text('Wood'), findsOneWidget); // picker option
    await tester.tap(find.text('Wood'));
    await tester.pumpAndSettle();

    expect(find.text('Wood'), findsOneWidget); // now the cell
    final tasks = await container.read(taskRepositoryProvider).list(1);
    final restock = tasks.firstWhere((t) => t.title == 'Restock 3mm plywood');
    expect(restock.customFields['material'], 'Wood');
  });

  testWidgets('checkbox cell toggles in place and persists', (tester) async {
    final container = await _pump(tester, fields: await _seededFields());

    await tester.tap(find
        .bySemanticsLabel(RegExp(r'^Approved: No, for Laser cutter monthly PM')));
    await tester.pumpAndSettle();

    final tasks = await container.read(taskRepositoryProvider).list(1);
    final pm = tasks.firstWhere((t) => t.title == 'Laser cutter monthly PM');
    expect(pm.customFields['approved'], true);

    // Toggle off clears the value entirely.
    await tester.tap(find
        .bySemanticsLabel(RegExp(r'^Approved: Yes, for Laser cutter monthly PM')));
    await tester.pumpAndSettle();
    final again = (await container.read(taskRepositoryProvider).list(1))
        .firstWhere((t) => t.title == 'Laser cutter monthly PM');
    expect(again.customFields.containsKey('approved'), isFalse);
  });

  testWidgets('number cell edits through the scalar dialog with validation',
      (tester) async {
    final container = await _pump(tester, fields: await _seededFields());

    await tester.tap(find
        .bySemanticsLabel(RegExp(r'^Weight: —, for Restock 3mm plywood')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('cf-editor')), 'heavy');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a number'), findsOneWidget); // rejected client-side

    await tester.enterText(find.byKey(const ValueKey('cf-editor')), '3.5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final tasks = await container.read(taskRepositoryProvider).list(1);
    expect(
        tasks
            .firstWhere((t) => t.title == 'Restock 3mm plywood')
            .customFields['weight_kg'],
        3.5);
  });

  testWidgets('popover adds a field: the new column appears', (tester) async {
    await _pump(tester, fields: InMemoryFieldRepository());
    expect(find.text('Sponsor'), findsNothing);

    await _openPopover(tester);
    await tester.tap(find.byKey(const ValueKey('add-field')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('field-label')), 'Sponsor');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last); // close the popover
    await tester.pumpAndSettle();
    await _flushSave(tester);

    expect(find.text('Sponsor'), findsNWidgets(6)); // header in every group
  });

  testWidgets('popover deletes a field: its column disappears', (tester) async {
    await _pump(tester, fields: await _seededFields());
    expect(find.text('Weight'), findsNWidgets(6));

    await _openPopover(tester);
    await tester.tap(find.byTooltip('Delete field Weight'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    await _flushSave(tester);

    expect(find.text('Weight'), findsNothing);
  });

  testWidgets('task dialog stages custom values and saves them on create',
      (tester) async {
    final container = await _pump(tester, fields: await _seededFields());

    await tester.tap(find.text('New item'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 'Cut acrylic sheet');
    // Stage a number value through the dialog's field row.
    await tester.tap(find.byKey(const ValueKey('dialog-cf:weight_kg')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('cf-editor')), '2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    final tasks = await container.read(taskRepositoryProvider).list(1);
    final created = tasks.firstWhere((t) => t.title == 'Cut acrylic sheet');
    expect(created.customFields['weight_kg'], 2);
  });
}
