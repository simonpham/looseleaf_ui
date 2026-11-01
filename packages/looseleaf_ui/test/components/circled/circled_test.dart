import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('loops once around every line, over the text', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 140,
          child: Circled(
            shape: CircledShape.box,
            bleed: 6,
            child: Text('a phrase long enough to wrap onto lines'),
          ),
        ),
      ),
    );
    await tester.pump();
    final mark = tester.widget<InkMark>(find.byType(InkMark));
    expect(mark.box, isTrue);
    expect(mark.over, isTrue);
    expect(mark.draw, InkMarkDraw.reveal);
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface)).source
                as RecipeInkSource<CircledParams>)
            .params;
    expect(params.shape, CircledShape.box);
    expect(params.bleed, 6);
  });

  testWidgets('animate draws the loop on with the surface reveal', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(const Circled(animate: true, child: Text('margins'))),
    );
    await tester.pump();
    InkSurface surface() => tester.widget<InkSurface>(find.byType(InkSurface));
    expect(surface().drawOn, isTrue);
    expect(surface().states, isEmpty);
    await tester.pump(const Duration(milliseconds: 10));
    expect(surface().states, {InkState.checked});
    await tester.pumpAndSettle();
  });
}
