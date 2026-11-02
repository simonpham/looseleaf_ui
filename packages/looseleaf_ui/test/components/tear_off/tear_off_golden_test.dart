import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _ticket({
  bool torn = false,
  Set<InkState> states = const {},
  String seed = 'ticket',
}) => Builder(
  builder: (context) {
    final theme = LooseleafTheme.of(context);
    final script = theme.typography.face(
      KevinSansFace.script,
      cssSize: 30,
      cssLineHeight: 1,
      color: theme.colors.ink,
    );
    final small = theme.typography.face(KevinSansFace.hand, cssSize: 14);
    return TearOff(
      defaultTorn: torn,
      children: [
        TearOffBody(
          width: 256,
          seed: '$seed-body',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Studio night', style: script),
              const SizedBox(height: Spacing.d8),
              Text('Friday, doors at 7', style: small),
              const SizedBox(height: Spacing.d12),
              Text(
                'admit one, keep this half',
                style: small.copyWith(color: theme.colors.pencilText),
              ),
            ],
          ),
        ),
        TearOffStub(
          width: 128,
          seed: '$seed-stub',
          forcedStates: states,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 0,
          padding: const EdgeInsets.fromLTRB(
            Spacing.d16,
            Spacing.d14,
            Spacing.d16,
            Spacing.d8,
          ),
          label: 'Tear off the 10% off coupon',
          children: [
            Text('10% off', style: script.copyWith(height: 30 / 22.5)),
            Text(
              'your next visit',
              style: small.copyWith(
                color: theme.colors.pencilText,
                height: 30 / 12.32,
              ),
            ),
          ],
        ),
      ],
    );
  },
);

Widget _coffee() => Builder(
  builder: (context) {
    final theme = LooseleafTheme.of(context);
    final script = theme.typography.face(
      KevinSansFace.script,
      cssSize: 30,
      cssLineHeight: 1,
      color: theme.colors.ink,
    );
    return TearOff(
      orientation: Axis.vertical,
      children: [
        TearOffBody(
          stock: StockName.kraft,
          width: 224,
          seed: 'coffee-body',
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d20,
            vertical: Spacing.d16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Coffee card', style: script),
              const SizedBox(height: Spacing.d8),
              Text(
                'nine stamped, one free',
                style: theme.typography.face(KevinSansFace.hand, cssSize: 14),
              ),
            ],
          ),
        ),
        TearOffStub(
          stock: StockName.stickyYellow,
          height: Spacing.d80,
          seed: 'coffee-stub',
          children: [Text('free coffee', style: script)],
        ),
      ],
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

  testWidgets('tear-off attached, focused, torn and vertical', (tester) async {
    tester.view.physicalSize = const Size(1800, 1300);
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d48,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d40,
                  children: [
                    _ticket(),
                    _ticket(states: {InkState.focused}, seed: 'focus'),
                    _ticket(torn: true, seed: 'torn'),
                  ],
                ),
                _coffee(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/tear-off-states.png'),
    );
  });

  testWidgets('tear-off mid-pull', (tester) async {
    tester.view.physicalSize = const Size(1000, 600);
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
            child: _ticket(),
          ),
        ),
      ),
    );
    final stub = tester.getCenter(find.byType(TearOffStub));
    final pull = await tester.startGesture(stub);
    await pull.moveBy(const Offset(30, 0));
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/tear-off-pulling.png'),
    );
    await pull.cancel();
    await tester.pumpAndSettle();
  });
}
