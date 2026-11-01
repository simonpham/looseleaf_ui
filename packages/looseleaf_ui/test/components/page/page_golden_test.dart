import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Future<void> _pump(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    componentHost(
      RepaintBoundary(
        child: Desk(padding: const EdgeInsets.all(Spacing.d32), child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('page-default in the light theme', (tester) async {
    await _pump(
      tester,
      const Size(800, 640),
      SizedBox(
        width: 672,
        child: PaperPage(
          seed: 'field-notes',
          children: [
            const PageHeader(
              children: [
                PageTitle(Text('Field notes'), seed: 'title'),
                PageDescription(
                  Text(
                    'A week of small observations, written where the light '
                    'was good.',
                  ),
                ),
              ],
            ),
            PageContent(
              children: [
                const Text(
                  'Most of what I remember from a book is in the margins: an '
                  'arrow, a question mark, a small argument with a dead '
                  'author. The rest is weather.',
                ),
                const Text(
                  'Tuesday. Rain on the window, three cups of tea, and one '
                  'very small plan for a very big week.',
                ),
                Button(
                  onPressed: () {},
                  seed: 'save',
                  child: const Text('Save the page'),
                ),
              ],
            ),
            const PageFooter(children: [Text('Draft'), Text('- 3 -')]),
          ],
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/page-default.png'),
    );
  });

  testWidgets('page-punched in the light theme', (tester) async {
    await _pump(
      tester,
      const Size(1180, 560),
      const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d40,
        children: [
          SizedBox(
            width: 340,
            height: 440,
            child: PaperPage(
              holes: PageHoles.start,
              reinforced: true,
              stain: true,
              width: PageWidth.sm,
              seed: 'binder',
              children: [
                PageHeader(
                  children: [
                    PageTitle(
                      Text('For the binder'),
                      underline: TitleMark.double,
                      seed: 'binder-title',
                    ),
                    PageDescription(Text('Three holes, gummed rings.')),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 340,
            height: 440,
            child: PaperPage(
              holes: PageHoles.top,
              stock: StockName.graph,
              width: PageWidth.sm,
              seed: 'legal',
              children: [
                PageHeader(
                  children: [
                    PageTitle(
                      Text('Filed at the top'),
                      underline: TitleMark.wavy,
                      seed: 'legal-title',
                    ),
                    PageDescription(Text('Two holes, a hand apart.')),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 340,
            child: PaperPage(
              torn: PageTorn.both,
              stock: StockName.pad,
              width: PageWidth.sm,
              seed: 'pad',
              children: [
                PageHeader(
                  children: [
                    PageTitle(
                      Text('Torn off'),
                      underline: TitleMark.highlight,
                      seed: 'pad-title',
                    ),
                  ],
                ),
                PageContent(children: [Text('Eggs, milk, more ink.')]),
              ],
            ),
          ),
        ],
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/page-punched.png'),
    );
  });
}
