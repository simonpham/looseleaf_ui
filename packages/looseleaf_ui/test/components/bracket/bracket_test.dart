import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('pads the side the bracket stands on', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Bracket(
          seed: 'b',
          child: SizedBox(width: 100, height: 60),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Bracket)), const Size(128, 60));
    expect(tester.getSize(find.byType(InkSurface)), const Size(128, 60));
    final box = tester.getTopLeft(find.byType(SizedBox).last);
    final host = tester.getTopLeft(find.byType(Bracket));
    expect(box.dx - host.dx, 28);
    await tester.pumpWidget(
      componentHost(
        const Bracket(
          side: BracketSide.end,
          child: SizedBox(width: 100, height: 60),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.byType(SizedBox).last),
      tester.getTopLeft(find.byType(Bracket)),
    );
  });

  testWidgets('passes kind, side and inset to the recipe', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Bracket(
          kind: BracketKind.curly,
          side: BracketSide.end,
          inset: 4,
          child: Text('passage'),
        ),
      ),
    );
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface)).source
                as RecipeInkSource<BracketParams>)
            .params;
    expect(params.kind, BracketKind.curly);
    expect(params.side, BracketSide.end);
    expect(params.inset, 4);
  });

  testWidgets('show false keeps the block and its padding', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Bracket(show: false, child: SizedBox(width: 100, height: 60)),
      ),
    );
    expect(find.byType(InkSurface), findsNothing);
    expect(tester.getSize(find.byType(Bracket)), const Size(128, 60));
  });
}
