import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

const LooseleafThemeData _calm = LooseleafThemeData(
  density: LooseleafDensity.calm,
);

void main() {
  testWidgets('sizes to its child plus padding', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Paper(
          seed: 's',
          padding: EdgeInsets.all(Spacing.d16),
          child: SizedBox(width: 100, height: 40),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Paper)), const Size(132, 72));
  });

  testWidgets('a cut sheet paints directly, a torn one draws the recipe', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Column(
          children: [
            Paper(seed: 'a', child: SizedBox(width: 80, height: 40)),
            Paper(
              seed: 'b',
              edge: EdgeSpec.all(EdgeKind.torn),
              child: SizedBox(width: 80, height: 40),
            ),
          ],
        ),
      ),
    );
    expect(find.byType(InkSurface), findsOneWidget);
  });

  testWidgets('calm cuts every edge and hides tape and fasteners', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Paper(
          seed: 'c',
          edge: EdgeSpec.all(EdgeKind.torn),
          curl: true,
          tape: PaperTape.both,
          fastener: FastenerKind.pin,
          child: SizedBox(width: 80, height: 40),
        ),
        theme: _calm,
      ),
    );
    expect(find.byType(InkSurface), findsNothing);
    expect(find.byType(Tape), findsNothing);
    expect(find.byType(PaperFastener), findsNothing);
  });

  testWidgets('lays tape strips and a fastener', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Paper(
          seed: 'd',
          tape: PaperTape.both,
          fastener: FastenerKind.clip,
          child: SizedBox(width: 120, height: 60),
        ),
      ),
    );
    expect(find.byType(Tape), findsNWidgets(2));
    expect(find.byType(PaperFastener), findsOneWidget);
  });

  testWidgets('the sheet tilts within the budget, flat when calm', (
    tester,
  ) async {
    double angleOf() {
      final transform = tester.widget<Transform>(
        find
            .descendant(
              of: find.byType(PaperBackground),
              matching: find.byType(Transform),
            )
            .first,
      );
      return transform.transform.getRotation().entry(1, 0);
    }

    await tester.pumpWidget(
      componentHost(
        const Paper(
          seed: 'e',
          tiltDegrees: 9,
          child: SizedBox(width: 80, height: 40),
        ),
      ),
    );
    expect(angleOf(), closeTo(0.0349, 0.0005));
    await tester.pumpWidget(
      componentHost(
        const Paper(
          seed: 'e',
          tiltDegrees: 9,
          child: SizedBox(width: 80, height: 40),
        ),
        theme: _calm,
      ),
    );
    expect(angleOf(), 0);
  });

  testWidgets('the sheet is decorative; the content keeps its semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const Paper(seed: 'f', tape: PaperTape.top, child: Text('Note')),
      ),
    );
    expect(find.bySemanticsLabel('Note'), findsOneWidget);
    handle.dispose();
  });

  test('shadows resolve per stock and density', () {
    expect(
      PaperShadow.stock.resolve(StockName.stickyYellow, calm: false),
      SheetShadowKind.sticky,
    );
    expect(
      PaperShadow.stock.resolve(StockName.card, calm: true),
      SheetShadowKind.hair,
    );
    expect(PaperShadow.none.resolve(StockName.paper, calm: false), isNull);
    expect(
      PaperShadow.lift.resolve(StockName.slip, calm: true),
      SheetShadowKind.lift,
    );
  });

  test('ruled stocks rest at a smaller tilt', () {
    final plain = PaperBackground.restingTilt(
      'x',
      StockName.paper,
      RuleName.none,
    );
    final ruled = PaperBackground.restingTilt(
      'x',
      StockName.paper,
      RuleName.ruled,
    );
    expect(ruled.abs(), lessThanOrEqualTo(0.6 * 0.45));
    expect(plain.abs(), lessThanOrEqualTo(0.6));
  });
}
