import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('lettering-sizes in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1900, 1500);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                for (final size in [
                  LetteringSize.sm,
                  LetteringSize.md,
                  LetteringSize.lg,
                ])
                  Lettering(size.name, size: size),
                Wrap(
                  spacing: Spacing.d32,
                  children: [
                    for (final tone in [
                      LetteringTone.teal,
                      LetteringTone.grape,
                      LetteringTone.bubblegum,
                      LetteringTone.grass,
                    ])
                      Lettering(tone.name, size: LetteringSize.md, tone: tone),
                  ],
                ),
                const Lettering(
                  'Two colors',
                  duotone: LetteringTone.sky,
                ),
                const Lettering(
                  'hand cut words',
                  tone: LetteringTone.teal,
                  wobble: 1.6,
                  seed: 'cut',
                ),
                const Lettering('Hero', size: LetteringSize.hero),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/lettering-sizes.png'),
    );
  });
}
