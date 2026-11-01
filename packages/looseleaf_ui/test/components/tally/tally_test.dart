import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('sizes itself to the count and reads it out', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const Tally(count: 7, seed: 't')));
    final box = tallyBox(7, 22);
    expect(tester.getSize(find.byType(InkSurface)), Size(box.w, box.h));
    expect(
      tester.getSemantics(find.byType(Tally)),
      matchesSemantics(label: '7', isImage: true),
    );
    handle.dispose();
  });

  testWidgets('clamps the count and takes a label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const Tally(count: 140, label: 'read many times')),
    );
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface)).source
                as RecipeInkSource<TallyParams>)
            .params;
    expect(params.count, 99);
    expect(find.bySemanticsLabel('read many times'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('sizes and a custom glyph height set the height', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(const Tally(count: 3, size: TallySize.lg)),
    );
    expect(tester.getSize(find.byType(InkSurface)).height, tallyBox(3, 34).h);
    await tester.pumpWidget(
      componentHost(const Tally(count: 3, glyphHeight: 50)),
    );
    expect(tester.getSize(find.byType(InkSurface)).height, tallyBox(3, 50).h);
  });

  testWidgets('mirrors in right-to-left text', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Tally(count: 4),
        ),
      ),
    );
    final params =
        (tester.widget<InkSurface>(find.byType(InkSurface)).source
                as RecipeInkSource<TallyParams>)
            .params;
    expect(params.rtl, isTrue);
  });
}
