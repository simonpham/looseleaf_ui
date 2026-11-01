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

  testWidgets('handwritten-strengths in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 440,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                for (final strength in [0.0, 0.5, 1.0, 2.0])
                  Handwritten(
                    'strength $strength: every word a hair off the line.',
                    strength: strength,
                    seed: 'hw',
                  ),
                Handwritten(
                  'ask sam about the pond, and bring the big umbrella!',
                  seed: 'note',
                  style: const LooseleafTypography().face(
                    KevinSansFace.script,
                    cssSize: 24,
                  ),
                ),
                const Handwritten.rich(
                  TextSpan(
                    text: 'Press ',
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: Text('Ctrl'),
                      ),
                      TextSpan(text: ' and carry on writing.'),
                    ],
                  ),
                  seed: 'rich',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/handwritten-strengths.png'),
    );
  });
}
