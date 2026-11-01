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

  testWidgets('napkin-folds in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1640, 1240);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.desk,
            child: const Padding(
              padding: EdgeInsets.all(Spacing.d40),
              child: Wrap(
                spacing: Spacing.d24,
                runSpacing: Spacing.d40,
                children: [
                  Napkin(
                    stain: true,
                    tape: PaperTape.top,
                    seed: 'specials',
                    children: [
                      NapkinTitle(Text('Specials')),
                      NapkinContent(Text('soup of the day, a very small pie')),
                      NapkinFooter(Text('until six')),
                    ],
                  ),
                  Napkin(
                    width: 208,
                    seed: 'q',
                    children: [
                      NapkinTitle(Text('Quarter')),
                      NapkinContent(Text('a crease each way')),
                    ],
                  ),
                  Napkin(
                    fold: NapkinFold.half,
                    stain: true,
                    width: 208,
                    seed: 'h',
                    children: [
                      NapkinTitle(Text('Half')),
                      NapkinContent(Text('and a cup stood here')),
                    ],
                  ),
                  Napkin(
                    fold: NapkinFold.none,
                    width: 208,
                    seed: 'f',
                    children: [
                      NapkinTitle(Text('Flat')),
                      NapkinContent(Text('never folded')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/napkin-folds.png'),
    );
  });
}
