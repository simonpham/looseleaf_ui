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

  testWidgets('underline-kinds in the light theme', (tester) async {
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
                for (final kind in UnderlineMarkKind.values)
                  Underline(
                    kind: kind,
                    seed: 'kind-${kind.name}',
                    child: Text('a ${kind.name} underline'),
                  ),
                for (final tone in [MarkPen.red, MarkPen.blue, MarkPen.pencil])
                  Underline(
                    tone: tone,
                    weight: MarkWeight.brush,
                    seed: 'tone-${tone.id}',
                    child: Text('${tone.id} brush'),
                  ),
                const Underline(
                  seed: 'wrap',
                  child: Text(
                    'the whole point of owning one is that it wraps onto '
                    'another line and the line follows the words',
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
      matchesGoldenFile('../goldens/underline-kinds.png'),
    );
  });
}
