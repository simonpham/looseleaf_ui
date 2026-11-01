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

  testWidgets('scribble-weights in the light theme', (tester) async {
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
                for (final weight in MarkWeight.values)
                  Scribble(
                    weight: weight,
                    seed: 'weight-${weight.name}',
                    child: Text('the first idea, ${weight.name}'),
                  ),
                for (final tone in [MarkPen.red, MarkPen.blue, MarkPen.pencil])
                  Scribble(
                    tone: tone,
                    seed: 'tone-${tone.id}',
                    child: Text('${tone.id} redaction'),
                  ),
                const Scribble(
                  seed: 'wrap',
                  child: Text(
                    'a scribble covers every line of a sentence that wraps '
                    'onto the next one',
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
      matchesGoldenFile('../goldens/scribble-weights.png'),
    );
  });
}
