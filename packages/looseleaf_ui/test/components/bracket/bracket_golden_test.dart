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

  testWidgets('bracket-kinds in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    const passage = Text(
      'Most of what I remember from a book is in the margins: an arrow, a '
      'question mark, a small argument with a dead author.',
    );
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 380,
            child: Column(
              spacing: Spacing.d20,
              children: [
                for (final kind in BracketKind.values)
                  Bracket(
                    kind: kind,
                    seed: 'kind-${kind.name}',
                    child: passage,
                  ),
                const Bracket(
                  side: BracketSide.end,
                  tone: MarkPen.red,
                  weight: MarkWeight.brush,
                  seed: 'end',
                  child: passage,
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
      matchesGoldenFile('../goldens/bracket-kinds.png'),
    );
  });
}
