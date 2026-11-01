import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

double _rotation(WidgetTester tester) =>
    tester.widget<InkArt>(find.byType(InkArt)).rotation;

void main() {
  testWidgets('is drawn at its length and height', (tester) async {
    await tester.pumpWidget(
      componentHost(const Tape(length: 90, height: 24, seed: 't')),
    );
    expect(tester.getSize(find.byType(Tape)), const Size(90, 24));
  });

  testWidgets('the angle is clamped to 2.5 times the tilt budget', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const Tape(angle: -38, seed: 't')));
    expect(_rotation(tester), closeTo(-5 * 3.14159265 / 180, 1e-6));
    await tester.pumpWidget(
      componentHost(
        const Tape(angle: -38, seed: 't'),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(_rotation(tester), 0);
  });

  testWidgets('casts the tape drop shadow and is decorative', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const Tape(seed: 't')));
    expect(tester.widget<InkArt>(find.byType(InkArt)).drop, DropKind.tape);
    expect(tester.getSemantics(find.byType(Tape)).label, isEmpty);
    handle.dispose();
  });
}
