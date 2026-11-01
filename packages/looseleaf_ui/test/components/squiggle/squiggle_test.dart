import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('fills the width at 16 px, or 16 px wide standing', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(const SizedBox(width: 200, child: Squiggle(seed: 's'))),
    );
    expect(tester.getSize(find.byType(InkSurface)), const Size(200, 16));
    await tester.pumpWidget(
      componentHost(
        const Squiggle(orientation: SquiggleOrientation.vertical, seed: 's'),
      ),
    );
    expect(tester.getSize(find.byType(InkSurface)), const Size(16, 32));
  });

  testWidgets('passes kind, tone and animate to the recipe', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 200,
          child: Squiggle(
            kind: SquiggleKind.loops,
            tone: MarkPen.red,
            animate: true,
          ),
        ),
      ),
    );
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface)).source
                as RecipeInkSource<SquiggleParams>)
            .params;
    expect(params.kind, SquiggleKind.loops);
    expect(params.tone, MarkPen.red);
    expect(params.animate, isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('decorative by default, a separator when asked', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const SizedBox(width: 200, child: Squiggle())),
    );
    expect(find.bySemanticsLabel('separator'), findsNothing);
    await tester.pumpWidget(
      componentHost(
        const SizedBox(width: 200, child: Squiggle(decorative: false)),
      ),
    );
    expect(find.bySemanticsLabel('separator'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('show false keeps the room and draws nothing', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(width: 200, child: Squiggle(show: false)),
      ),
    );
    expect(find.byType(InkSurface), findsNothing);
    expect(tester.getSize(find.byType(Squiggle)), const Size(200, 16));
  });
}
