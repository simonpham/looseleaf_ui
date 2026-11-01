import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _grid() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d24,
  children: [
    for (final effect in RevealEffect.values)
      Reveal(effect: effect, child: Text('A line revealed by ${effect.name}')),
    const Reveal(nib: true, child: Text('A wipe carrying the nib along')),
    const Reveal(
      from: RevealFrom.end,
      child: Text('A wipe from the reading end'),
    ),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  for (final (name, time) in [
    ('mid', const Duration(milliseconds: 150)),
    ('settled', const Duration(seconds: 2)),
  ]) {
    testWidgets('reveal-$name in the light theme', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(componentHost(goldenPanel(_grid())));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(time);
      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile('../goldens/reveal-$name.png'),
      );
      await tester.pumpAndSettle();
    });
  }
}
