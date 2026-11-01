import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

const _long = 'a phrase long enough to wrap onto lines';

void main() {
  testWidgets('strokes over each line of the text', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(width: 140, child: Strike(child: Text(_long))),
      ),
    );
    await tester.pump();
    final mark = tester.widget<InkMark>(find.byType(InkMark));
    expect(mark.over, isTrue);
    expect(mark.box, isFalse);
    expect(find.byType(InkSurface).evaluate().length, greaterThan(1));
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface).first).source
                as RecipeInkSource<StrikeParams>)
            .params;
    expect(params.tone, MarkPen.red);
  });

  testWidgets('cross draws one mark around every line', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 140,
          child: Strike(kind: StrikeKind.cross, child: Text(_long)),
        ),
      ),
    );
    await tester.pump();
    expect(tester.widget<InkMark>(find.byType(InkMark)).box, isTrue);
    expect(find.byType(InkSurface), findsOneWidget);
  });
}
