import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('sits in an 80 by 40 box and passes its shape', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Arrow(
          direction: ArrowDirection.downLeft,
          curve: ArrowCurve.curl,
          head: ArrowHead.solid,
          bend: ArrowBend.down,
        ),
      ),
    );
    expect(tester.getSize(find.byType(InkSurface)), const Size(80, 40));
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface)).source
                as RecipeInkSource<ArrowParams>)
            .params;
    expect(params.direction, ArrowDirection.downLeft);
    expect(params.curve, ArrowCurve.curl);
    expect(params.head, ArrowHead.solid);
    expect(params.bend, ArrowBend.down);
    expect(params.dx, isNull);
  });

  testWidgets('the label sits behind the tail', (tester) async {
    await tester.pumpWidget(
      componentHost(const Arrow(label: Text('ha, true'))),
    );
    final arrow = tester.getRect(find.byType(InkSurface));
    final label = tester.getRect(find.text('ha, true'));
    expect(label.right, arrow.left - 8);
    expect(label.center.dy, closeTo(arrow.center.dy, 0.5));
    await tester.pumpWidget(
      componentHost(
        const Arrow(direction: ArrowDirection.left, label: Text('note')),
      ),
    );
    expect(
      tester.getRect(find.text('note')).left,
      tester.getRect(find.byType(InkSurface)).right + 8,
    );
  });

  testWidgets('width and height size the box, h-12 w-40', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Arrow(
          width: Spacing.d160,
          height: Spacing.d48,
          label: Text('here'),
        ),
      ),
    );
    final arrow = tester.getRect(find.byType(InkSurface));
    expect(arrow.size, const Size(Spacing.d160, Spacing.d48));
    expect(tester.getRect(find.text('here')).right, arrow.left - 8);
  });

  testWidgets('a label under an up arrow clears a taller box', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Arrow(
          direction: ArrowDirection.up,
          height: Spacing.d80,
          label: Text('up'),
        ),
      ),
    );
    expect(
      tester.getRect(find.text('up')).top,
      tester.getRect(find.byType(InkSurface)).bottom + 4,
    );
  });

  testWidgets('aims at a target, stopping short by the gap', (tester) async {
    final target = GlobalKey();
    await tester.pumpWidget(
      componentHost(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Arrow(pointAt: target, gap: 6),
            const SizedBox(width: 100),
            SizedBox(key: target, width: 40, height: 24),
          ],
        ),
      ),
    );
    expect(find.byType(InkSurface), findsNothing);
    await tester.pump();
    expect(tester.getSize(find.byType(InkSurface)), const Size(24, 24));
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface)).source
                as RecipeInkSource<ArrowParams>)
            .params;
    expect(params.dx, 100 + 12 - 6);
    expect(params.dy, 0);
  });

  test('arrowVector stops at the target edge', () {
    expect(
      arrowVector(
        const Rect.fromLTWH(0, 0, 20, 20),
        const Rect.fromLTWH(100, 0, 20, 20),
        4,
      ),
      const Offset(86, 0),
    );
    expect(
      arrowVector(
        const Rect.fromLTWH(0, 0, 20, 20),
        const Rect.fromLTWH(0, 0, 40, 40),
        4,
      ),
      isNull,
    );
  });
}
