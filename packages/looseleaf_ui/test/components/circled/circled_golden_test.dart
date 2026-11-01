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

  testWidgets('circled-shapes in the light theme', (tester) async {
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
                for (final shape in CircledShape.values)
                  Circled(
                    shape: shape,
                    seed: 'shape-${shape.name}',
                    child: Text('a ${shape.name}'),
                  ),
                for (final tone in [MarkPen.red, MarkPen.blue, MarkPen.green])
                  Circled(
                    tone: tone,
                    weight: MarkWeight.brush,
                    seed: 'tone-${tone.id}',
                    child: Text('${tone.id} brush'),
                  ),
                const Circled(
                  bleed: 8,
                  seed: 'bleed',
                  child: Text('more bleed'),
                ),
                const Circled(
                  seed: 'wrap',
                  child: Text(
                    'a loop goes around the whole phrase even when it wraps '
                    'onto two lines',
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
      matchesGoldenFile('../goldens/circled-shapes.png'),
    );
  });
}
