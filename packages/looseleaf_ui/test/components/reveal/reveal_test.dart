import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

double _opacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(
        of: find.byType(RevealMotion),
        matching: find.byType(Opacity),
      ),
    )
    .opacity;

void main() {
  test('keyframes start hidden and settle', () {
    for (final effect in RevealEffect.values) {
      expect(effect.poseAt(1).opacity, 1, reason: effect.name);
      expect(effect.poseAt(1).offset, Offset.zero, reason: effect.name);
    }
    expect(RevealEffect.drop.poseAt(0).offset, const Offset(0, -26));
    expect(RevealEffect.toss.poseAt(0).opacity, 0);
    expect(RevealEffect.soak.poseAt(0).wet, 1);
    expect(RevealEffect.pop.poseAt(0).scale, 0.7);
  });

  testWidgets('waits for the delay, then plays', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Reveal(
          effect: RevealEffect.pop,
          delay: Duration(milliseconds: 100),
          child: Text('Hello'),
        ),
      ),
    );
    expect(_opacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 90));
    expect(_opacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 20));
    expect(_opacity(tester), lessThan(1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_opacity(tester), 1);
    await tester.pumpAndSettle();
  });

  testWidgets('the content is read from the start', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const Reveal(effect: RevealEffect.toss, child: Text('Hidden ink')),
      ),
    );
    expect(find.bySemanticsLabel('Hidden ink'), findsOneWidget);
    await tester.pumpAndSettle();
    handle.dispose();
  });

  testWidgets('stagger delays each child', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Reveal.stagger(
          stagger: Duration(milliseconds: 200),
          effect: RevealEffect.soak,
          children: [Text('one'), Text('two'), Text('three')],
        ),
      ),
    );
    final delays = tester
        .widgetList<RevealMotion>(find.byType(RevealMotion))
        .map((m) => m.delay);
    expect(delays, const [
      Duration.zero,
      Duration(milliseconds: 200),
      Duration(milliseconds: 400),
    ]);
    await tester.pumpAndSettle();
  });

  testWidgets('a wipe can carry the nib; other effects cannot', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(const Reveal(nib: true, child: Text('nib'))),
    );
    expect(find.byType(RevealNib), findsOneWidget);
    expect(find.byType(InkMarkWipe), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      componentHost(
        const Reveal(nib: true, effect: RevealEffect.drop, child: Text('no')),
      ),
    );
    expect(find.byType(RevealNib), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion just shows it', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Reveal(
          effect: RevealEffect.drop,
          delay: Duration(seconds: 1),
          child: Text('still'),
        ),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    expect(_opacity(tester), 1);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
