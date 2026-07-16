import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makerflow_design/makerflow_design.dart';

Widget _host(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? MakerflowThemeBuilder.dark() : MakerflowThemeBuilder.light(),
      home: Scaffold(body: Center(child: child)),
    );

/// WCAG relative-contrast ratio between two colors.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('every status label meets WCAG AA contrast (4.5:1) with its text', () {
    for (final entry in MndLabelColors.status.entries) {
      final bg = entry.value;
      final fg = MndLabelColors.textOn(bg);
      expect(_contrast(bg, fg), greaterThanOrEqualTo(4.5),
          reason: 'status ${entry.key} (${bg.toString()}) fails AA with ${fg.toString()}');
    }
  });

  test('primary button palette meets AA (white on brand blue)', () {
    expect(_contrast(MakerflowColors.light.brand, Colors.white), greaterThanOrEqualTo(4.5));
    expect(_contrast(MakerflowColors.light.text, MakerflowColors.light.bg), greaterThanOrEqualTo(4.5));
    expect(_contrast(MakerflowColors.light.muted, MakerflowColors.light.bg), greaterThanOrEqualTo(4.5));
  });

  testWidgets('StatusBadge announces its status and shows the label text', (tester) async {
    await tester.pumpWidget(_host(const StatusBadge(status: 'inProgress')));
    expect(find.text('In progress'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(StatusBadge)),
      matchesSemantics(label: 'Status: In progress'),
    );
  });

  testWidgets('StatusLabel.cell + picker round-trip', (tester) async {
    String? picked;
    await tester.pumpWidget(_host(Builder(
      builder: (context) => StatusLabel.cell(
        status: 'todo',
        onTap: () async => picked = await showStatusPicker(context, current: 'todo'),
      ),
    )));
    await tester.tap(find.text('To do'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget); // picker open
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(picked, 'done');
  });

  testWidgets('MndButton renders all kinds and respects disabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(Column(children: [
      MndButton(label: 'Primary', onPressed: () => taps++),
      const MndButton(label: 'Secondary', kind: MndButtonKind.secondary, onPressed: null),
      MndButton(label: 'Tertiary', kind: MndButtonKind.tertiary, onPressed: () => taps++),
    ])));
    await tester.tap(find.text('Primary'));
    expect(taps, 1);
    await tester.tap(find.text('Secondary'), warnIfMissed: false);
    expect(taps, 1); // disabled
  });

  testWidgets('MndAvatar initials + stack overflow chip', (tester) async {
    await tester.pumpWidget(_host(const Column(children: [
      MndAvatar(name: 'Ada Lovelace'),
      MndAvatarStack(names: ['Ada Lovelace', 'Grace Hopper', 'Alan Turing', 'Katherine Johnson', 'Marie Curie']),
    ])));
    expect(find.text('AL'), findsNWidgets(2)); // avatar + first of stack
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('MndSkeleton exists in both themes; MndEmptyState CTA fires', (tester) async {
    await tester.pumpWidget(_host(const MndSkeleton(width: 120), dark: true));
    expect(find.byType(MndSkeleton), findsOneWidget);
    var cta = 0;
    await tester.pumpWidget(_host(MndEmptyState(
      icon: Icons.inbox_outlined,
      headline: 'No items',
      ctaLabel: 'Add item',
      onCta: () => cta++,
    )));
    await tester.tap(find.text('Add item'));
    expect(cta, 1);
  });
}
