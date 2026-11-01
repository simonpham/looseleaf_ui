import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('is at most 448 wide, at least 224 tall, parts on the grid', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const IndexCard(
          seed: 'c',
          children: [
            IndexCardHeader(children: [IndexCardTitle(Text('Recipes'))]),
            IndexCardContent(children: [Text('soup'), Text('toast')]),
            IndexCardFooter(children: [Text('no. 42'), Text('p. 3')]),
          ],
        ),
      ),
    );
    final card = tester.getRect(find.byType(IndexCard));
    expect(card.size, const Size(448, 224));
    expect(tester.getSize(find.byType(IndexCardHeader)).height, 49);
    expect(
      tester.getTopLeft(find.byType(IndexCardHeader)),
      card.topLeft + const Offset(20, 0),
    );
    expect(tester.getSize(find.text('soup')).height, closeTo(30, 0.5));
    expect(tester.getTopLeft(find.text('soup')).dy, card.top + 49);
    expect(
      tester.getBottomLeft(find.byType(IndexCardFooter)).dy,
      card.bottom - 25,
    );
    expect(
      tester.getTopRight(find.text('p. 3')).dx,
      card.right - 20,
    );
  });

  testWidgets('shrinks to a narrow parent', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(width: 300, child: IndexCard(seed: 'c')),
      ),
    );
    expect(tester.getSize(find.byType(IndexCard)).width, 300);
  });

  testWidgets('a long title stays on one line with an ellipsis', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        IndexCard(
          maxWidth: 240,
          seed: 'c',
          children: [
            IndexCardHeader(
              children: [IndexCardTitle(Text('a very long title ' * 4))],
            ),
          ],
        ),
      ),
    );
    final text = tester.widget<RichText>(
      find.descendant(
        of: find.byType(IndexCardTitle),
        matching: find.byType(RichText),
      ),
    );
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('draws the decor only for a hole, a flag or a pile', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const IndexCard(seed: 'c')));
    expect(_decor(tester), isEmpty);
    for (final card in const [
      IndexCard(hole: true, seed: 'c'),
      IndexCard(flag: Accent.sky, seed: 'c'),
      IndexCard(stack: 2, seed: 'c'),
    ]) {
      await tester.pumpWidget(componentHost(card));
      expect(_decor(tester).single.seed, 'c|decor');
    }
  });

  testWidgets('sits on index stock with index rules, mirrored in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const IndexCard(seed: 'c'),
        theme: const LooseleafThemeData(textDirection: TextDirection.rtl),
      ),
    );
    final paper = tester.widget<Paper>(find.byType(Paper));
    expect(paper.stock, StockName.indexCard);
    expect(paper.rules, RuleName.indexCard);
    expect(paper.mirrorRules, isTrue);
    expect(paper.tiltDegrees?.abs(), lessThanOrEqualTo(0.225));
  });

  testWidgets('the title is a header', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const IndexCard(
          children: [
            IndexCardHeader(children: [IndexCardTitle(Text('Words'))]),
          ],
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(IndexCardTitle)),
      matchesSemantics(label: 'Words', isHeader: true),
    );
    handle.dispose();
  });
}

List<InkSurface> _decor(WidgetTester tester) => tester
    .widgetList<InkSurface>(find.byType(InkSurface))
    .where((surface) => surface.seed.endsWith('|decor'))
    .toList();
