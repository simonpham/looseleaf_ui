import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _sale({
  bool open = false,
  PeelCornerSide corner = PeelCornerSide.bottomRight,
  Set<InkState> states = const {},
  String seed = 'sale',
}) => Builder(
  builder: (context) {
    final theme = LooseleafTheme.of(context);
    final script = theme.typography.face(
      KevinSansFace.script,
      cssSize: 36,
      cssLineHeight: 1,
      color: theme.colors.ink,
    );
    final small = theme.typography.face(KevinSansFace.hand, cssSize: 14);
    return SizedBox(
      width: 320,
      child: PeelCorner(
        defaultPeeled: open,
        corner: corner,
        seed: seed,
        forcedStates: states,
        children: [
          PeelCornerPage(
            seed: '$seed-page',
            child: SizedBox(
              height: 168,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spring sale', style: script),
                  const SizedBox(height: Spacing.d8),
                  Text('Everything in the shop, one week only.', style: small),
                  const SizedBox(height: Spacing.d4),
                  Text(
                    'Peek under the corner for a code.',
                    style: small.copyWith(color: theme.colors.pencilText),
                  ),
                ],
              ),
            ),
          ),
          PeelCornerUnder(
            seed: '$seed-under',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: switch (corner) {
                PeelCornerSide.bottomRight => CrossAxisAlignment.end,
                PeelCornerSide.bottomLeft => CrossAxisAlignment.start,
              },
              children: [
                Text('SAVE10', style: script),
                Text(
                  'ten off your next order',
                  style: small.copyWith(color: theme.colors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('peel-corner closed, open, left and focused', (tester) async {
    tester.view.physicalSize = const Size(1700, 1200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: Paper(
            stock: StockName.dotGrid,
            tilt: false,
            shadow: PaperShadow.none,
            seed: 'page',
            padding: const EdgeInsets.all(Spacing.d40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d40,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d40,
                  children: [
                    _sale(),
                    _sale(open: true, seed: 'open'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d40,
                  children: [
                    _sale(
                      corner: PeelCornerSide.bottomLeft,
                      open: true,
                      seed: 'left',
                    ),
                    _sale(states: {InkState.focused}, seed: 'focus'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/peel-corner-states.png'),
    );
  });
}
