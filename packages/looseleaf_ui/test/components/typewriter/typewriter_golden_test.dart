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

  testWidgets('typewriter-carets in the light theme', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                for (final shape in CaretShape.values)
                  Typewriter('Dear diary, a ${shape.name}', cursor: shape),
                Typewriter('No caret at all', cursor: null),
                const Typewriter.phrases([
                  'Two lines typed,',
                  'one under the other.',
                ], style: TextStyle(fontSize: 22)),
              ],
            ),
          ),
        ),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/typewriter-carets.png'),
    );
  });

  testWidgets('typewriter-typing halfway through', (tester) async {
    tester.view.physicalSize = const Size(800, 300);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 300,
            child: Typewriter(
              'Dear diary, today I shipped it.',
              seed: 'golden',
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/typewriter-typing.png'),
    );
    await tester.pump(const Duration(seconds: 5));
  });
}
