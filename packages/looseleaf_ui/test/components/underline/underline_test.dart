import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('draws under the text, one line per line', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 140,
          child: Underline(
            seed: 'u',
            child: Text('a phrase long enough to wrap onto lines'),
          ),
        ),
      ),
    );
    await tester.pump();
    final mark = tester.widget<InkMark>(find.byType(InkMark));
    expect(mark.over, isFalse);
    expect(mark.box, isFalse);
    expect(mark.draw, InkMarkDraw.wipe);
    expect(find.byType(InkMarkSurface).evaluate().length, greaterThan(1));
  });

  testWidgets('passes kind, tone and weight to the recipe', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Underline(
          kind: UnderlineMarkKind.wavy,
          tone: MarkPen.red,
          weight: MarkWeight.brush,
          seed: 'u',
          child: Text('red pencil'),
        ),
      ),
    );
    await tester.pump();
    final source =
        tester.widget<InkSurface>(find.byType(InkSurface)).source
            as RecipeInkSource<UnderlineParams>;
    expect(source.params.kind, UnderlineMarkKind.wavy);
    expect(source.params.tone, MarkPen.red);
    expect(source.params.weight, MarkWeight.brush);
    expect(source.params.line.n, 1);
  });

  testWidgets('show false hides the line, the text stays', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Underline(show: false, child: Text('no line')),
      ),
    );
    await tester.pump();
    expect(find.byType(InkSurface), findsNothing);
    expect(find.text('no line'), findsOneWidget);
  });
}
