import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('swipes behind the text, one swipe per line', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 140,
          child: Highlight(
            seed: 'h',
            child: Text('a phrase long enough to wrap onto lines'),
          ),
        ),
      ),
    );
    await tester.pump();
    final mark = tester.widget<InkMark>(find.byType(InkMark));
    expect(mark.over, isFalse);
    expect(mark.draw, InkMarkDraw.wipe);
    final sources = tester
        .widgetList<InkSurface>(find.byType(InkSurface))
        .map((s) => (s.source as RecipeInkSource<HighlightParams>).params)
        .toList();
    expect(sources.length, greaterThan(1));
    expect(sources.first.line.first, isTrue);
    expect(sources.last.line.last, isTrue);
  });

  testWidgets('passes tone, weight and cover to the recipe', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Highlight(
          tone: HighlightTone.green,
          weight: HighlightWeight.heavy,
          cover: HighlightCover.under,
          child: Text('third reading'),
        ),
      ),
    );
    await tester.pump();
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface)).source
                as RecipeInkSource<HighlightParams>)
            .params;
    expect(params.tone, HighlightTone.green);
    expect(params.fat, 1.22);
    expect(params.cover, HighlightCover.under);
  });

  testWidgets('animate wipes the swipe in after the delay', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Highlight(
          animate: true,
          delay: Duration(milliseconds: 200),
          child: Text('drawn on'),
        ),
      ),
    );
    await tester.pump();
    final surface = tester.widget<InkMarkSurface>(find.byType(InkMarkSurface));
    expect(surface.animate, isTrue);
    expect(surface.delay, const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  });
}
