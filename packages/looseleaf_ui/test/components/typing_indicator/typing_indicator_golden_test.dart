import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _grid() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d16,
  children: [
    for (final variant in TypingVariant.values)
      for (final pen in TypingPen.values)
        TypingIndicator(
          variant: variant,
          pen: pen,
          seed: '${variant.name}-${pen.name}',
        ),
    const TypingIndicator(pencil: false, seed: 'no-pencil'),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('typing-indicator-variants in the light theme', (tester) async {
    tester.view.physicalSize = const Size(600, 600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(_grid()),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/typing-indicator-variants.png'),
    );
  });

  testWidgets('typing-indicator-mid-cycle in the light theme', (tester) async {
    tester.view.physicalSize = const Size(600, 600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(componentHost(goldenPanel(_grid())));
    await tester.pump(const Duration(milliseconds: 650));
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/typing-indicator-mid-cycle.png'),
    );
  });
}
