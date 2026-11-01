import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _note(BuildContext context, String text) {
  final theme = LooseleafTheme.of(context);
  return Text(
    text,
    style: theme.typography.face(
      KevinSansFace.hand,
      cssSize: 14,
      cssLineHeight: 20 / 14,
      color: theme.colors.pencilText,
    ),
  );
}

Widget _cat({bool flipped = false, Set<InkState> states = const {}}) => Builder(
  builder: (context) => FlipCard(
    defaultFlipped: flipped,
    label: 'Show the answer',
    trigger: false,
    children: [
      FlipCardFront(
        seed: 'front',
        children: [
          const Text('le chat', style: TextStyle(fontSize: 27)),
          _note(context, '(masculine noun)'),
        ],
      ),
      FlipCardBack(
        seed: 'back',
        children: [
          const Text('the cat', style: TextStyle(fontSize: 27)),
          _note(context, 'purrs, ignores you'),
        ],
      ),
      Positioned.fill(
        child: FlipCardTrigger(seed: 'trigger', forcedStates: states),
      ),
    ],
  ),
);

Widget _notepad() => const FlipCard(
  axis: FlipCardAxis.x,
  width: 256,
  height: 208,
  label: 'Turn the page',
  children: [
    FlipCardFront(
      stock: StockName.stickyYellow,
      seed: 'pad',
      children: [
        Text('pancakes', style: TextStyle(fontSize: 24)),
        Text('turn me over for the recipe', style: TextStyle(fontSize: 13)),
      ],
    ),
    FlipCardBack(
      stock: StockName.indexCard,
      seed: 'recipe',
      children: [Text('2 eggs, 200 g flour')],
    ),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('flip-card faces and the trigger', (tester) async {
    tester.view.physicalSize = const Size(1600, 1400);
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
                    _cat(),
                    _cat(flipped: true, states: {InkState.hovered}),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d40,
                  children: [
                    _cat(states: {InkState.focused}),
                    _notepad(),
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
      matchesGoldenFile('../goldens/flip-card-faces.png'),
    );
  });

  testWidgets('flip-card mid-turn', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
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
            child: _cat(),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(FlipCardTrigger));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/flip-card-turning.png'),
    );
    await tester.pumpAndSettle();
  });
}
