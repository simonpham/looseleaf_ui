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

  testWidgets('strike-kinds in the light theme', (tester) async {
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
                for (final kind in StrikeKind.values)
                  Strike(
                    kind: kind,
                    seed: 'kind-${kind.name}',
                    child: Text('struck ${kind.name}'),
                  ),
                for (final tone in [MarkPen.ink, MarkPen.blue, MarkPen.pencil])
                  Strike(
                    tone: tone,
                    weight: MarkWeight.fine,
                    seed: 'tone-${tone.id}',
                    child: Text('${tone.id} fine'),
                  ),
                const Strike(
                  kind: StrikeKind.cross,
                  seed: 'wrap-cross',
                  child: Text(
                    'a whole paragraph crossed off at once, because it ran '
                    'onto two lines',
                  ),
                ),
                const Strike(
                  seed: 'wrap',
                  child: Text(
                    'a single stroke follows each line of a phrase that wraps '
                    'onto the next line',
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
      matchesGoldenFile('../goldens/strike-kinds.png'),
    );
  });
}
