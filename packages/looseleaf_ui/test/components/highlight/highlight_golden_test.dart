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

  testWidgets('highlight-tones in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                for (final tone in HighlightTone.values)
                  Highlight(
                    tone: tone,
                    seed: 'tone-${tone.id}',
                    child: Text('a swipe of ${tone.id}'),
                  ),
                for (final weight in HighlightWeight.values)
                  Highlight(
                    weight: weight,
                    cover: HighlightCover.under,
                    seed: 'under-${weight.name}',
                    child: Text('under, ${weight.name}'),
                  ),
                const Highlight(
                  tone: HighlightTone.pink,
                  seed: 'wrap',
                  child: Text(
                    'that the margin is where the reading happens, and the '
                    'page is only where it starts',
                  ),
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
      matchesGoldenFile('../goldens/highlight-tones.png'),
    );
  });
}
