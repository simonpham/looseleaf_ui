import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('the arrow sits on the side it points to', (tester) async {
    for (final (direction, arrowAfter) in [
      (ArrowDirection.left, false),
      (ArrowDirection.right, true),
      (ArrowDirection.downLeft, false),
      (ArrowDirection.upRight, true),
    ]) {
      await tester.pumpWidget(
        componentHost(Callout('ask sam', direction: direction, seed: 'c')),
      );
      final arrow = tester.getCenter(find.byType(InkMarkSurface));
      final text = tester.getCenter(find.byType(Handwritten));
      expect(arrow.dx > text.dx, arrowAfter, reason: direction.id);
    }
  });

  testWidgets('stacked directions put the arrow above or below', (
    tester,
  ) async {
    for (final (direction, arrowBelow) in [
      (ArrowDirection.down, true),
      (ArrowDirection.up, false),
    ]) {
      await tester.pumpWidget(
        componentHost(Callout('so true', direction: direction, seed: 'c')),
      );
      final arrow = tester.getCenter(find.byType(InkMarkSurface));
      final text = tester.getCenter(find.byType(Handwritten));
      expect(arrow.dy > text.dy, arrowBelow, reason: direction.id);
    }
  });

  testWidgets('the arrow is 56 × 40 and seeded from the note', (tester) async {
    await tester.pumpWidget(componentHost(const Callout('hi', seed: 'n')));
    expect(tester.getSize(find.byType(InkMarkSurface)), const Size(56, 40));
    expect(
      tester.widget<InkMarkSurface>(find.byType(InkMarkSurface)).seed,
      'n:arrow',
    );
  });

  testWidgets('no arrow, and hidden when not shown', (tester) async {
    await tester.pumpWidget(
      componentHost(const Callout('hi', arrow: false)),
    );
    expect(find.byType(InkMarkSurface), findsNothing);
    await tester.pumpWidget(componentHost(const Callout('hi', show: false)));
    expect(find.byType(Handwritten), findsNothing);
  });

  testWidgets('long words wrap at 16 characters', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Callout('this sentence is much longer than sixteen characters'),
      ),
    );
    final lines =
        tester.getSize(find.byType(Handwritten)).height /
        const LooseleafThemeData().typography
            .face(KevinSansFace.script, cssSize: 22, cssLineHeight: 1.05)
            .fontSize!;
    expect(lines, greaterThan(2));
  });

  testWidgets('animated words fade in after the delay', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Callout(
          'later',
          animate: true,
          delay: Duration(milliseconds: 100),
        ),
      ),
    );
    double opacity() =>
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
    expect(opacity(), 0);
    await tester.pump(const Duration(milliseconds: 120));
    expect(opacity(), 1);
    await tester.pumpAndSettle();
  });

  testWidgets('reads as its words', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const Callout('check the date!')));
    expect(find.bySemanticsLabel('check the date!'), findsOneWidget);
    handle.dispose();
  });
}
