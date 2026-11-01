import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('scribbles over the text with tone and weight', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Scribble(
          tone: MarkPen.blue,
          weight: MarkWeight.brush,
          child: Text('redacted'),
        ),
      ),
    );
    await tester.pump();
    expect(tester.widget<InkMark>(find.byType(InkMark)).over, isTrue);
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface)).source
                as RecipeInkSource<ScribbleParams>)
            .params;
    expect(params.tone, MarkPen.blue);
    expect(params.weight, MarkWeight.brush);
    expect(find.text('redacted'), findsOneWidget);
  });
}
