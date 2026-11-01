import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/ibm_plex_mono.dart';
import '../../support/kevin_sans.dart';

Widget _scale() => const SizedBox(
  width: 560,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      H1(child: Text('Notes on keeping a notebook')),
      SizedBox(height: Spacing.d16),
      Lead(
        child: Text(
          'A notebook is a small argument you have with yourself, one page '
          'at a time.',
        ),
      ),
      SizedBox(height: Spacing.d20),
      P(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text:
                    'Most of what I remember from a book is in the margins. '
                    'Run ',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: InlineCode('npm run notes'),
              ),
              TextSpan(text: ' if you want it on the screen.'),
            ],
          ),
        ),
      ),
      SizedBox(height: Spacing.d32),
      H2(child: Text('What goes in the margin')),
      SizedBox(height: Spacing.d16),
      TypographyList(
        children: [
          Text('A question you cannot answer yet'),
          Text('A disagreement, politely worded'),
        ],
      ),
      SizedBox(height: Spacing.d8),
      TypographyList(
        ordered: true,
        children: [Text('Write it down'), Text('Read it back')],
      ),
      SizedBox(height: Spacing.d24),
      H3(child: Text('A word from someone who knew')),
      SizedBox(height: Spacing.d24),
      Blockquote(
        seed: 'quote',
        child: Text('The best time to write it down was when it happened.'),
      ),
      SizedBox(height: Spacing.d24),
      H4(child: Text('Small print')),
      SizedBox(height: Spacing.d4),
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: Spacing.d24,
        children: [
          Large(child: Text('Large')),
          Small(child: Text('Small')),
          Muted(child: Text('Muted, for captions')),
        ],
      ),
    ],
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
      await loadIbmPlexMono();
    });
  });

  testWidgets('typography-scale in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1300, 1800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.paper,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d24),
              child: _scale(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/typography-scale.png'),
    );
  });
}
