import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

const Key _title = Key('title');
const Key _action = Key('action');
const Key _body = Key('body');

Widget _card({bool headerDivider = false, bool footerDivider = false}) =>
    SizedBox(
      width: 300,
      child: Card(
        seed: 'c',
        children: [
          CardHeader(
            divider: headerDivider,
            children: const [
              CardTitle(Text('Title', key: _title)),
              CardDescription(Text('Description')),
              CardAction(child: SizedBox(key: _action, width: 40, height: 20)),
            ],
          ),
          const CardContent(child: SizedBox(key: _body, height: 30)),
          CardFooter(divider: footerDivider, children: const [Text('Foot')]),
        ],
      ),
    );

void main() {
  testWidgets('is a card-stock paper with 24 px around and between parts', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_card()));
    final paper = tester.widget<Paper>(find.byType(Paper));
    expect(paper.stock, StockName.card);
    expect(paper.rules, RuleName.none);
    final card = tester.getRect(find.byType(Card));
    final title = tester.getRect(find.byKey(_title));
    final body = tester.getRect(find.byKey(_body));
    expect(title.top - card.top, Spacing.d24);
    expect(title.left - card.left, Spacing.d24);
    expect(body.left - card.left, Spacing.d24);
    expect(body.width, 300 - 2 * Spacing.d24);
  });

  testWidgets('the action sits at the header top end', (tester) async {
    await tester.pumpWidget(componentHost(_card()));
    final card = tester.getRect(find.byType(Card));
    final action = tester.getRect(find.byKey(_action));
    expect(card.right - action.right, Spacing.d24);
    expect(action.top, tester.getRect(find.byKey(_title)).top);
  });

  testWidgets('dividers draw card rules and add 24 px of room', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_card()));
    expect(find.byType(CardRule), findsNothing);
    final plain = tester.getSize(find.byType(Card)).height;
    await tester.pumpWidget(
      componentHost(_card(headerDivider: true, footerDivider: true)),
    );
    final rules = tester.widgetList<CardRule>(find.byType(CardRule));
    expect(rules.map((rule) => rule.edge), [
      CardRuleEdge.bottom,
      CardRuleEdge.top,
    ]);
    expect(tester.getSize(find.byType(Card)).height, plain + 2 * Spacing.d24);
  });

  testWidgets('the title is a header', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(_card()));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Title')),
      matchesSemantics(label: 'Title', isHeader: true),
    );
    handle.dispose();
  });

  testWidgets('a centred header centres the title and its lines', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: Card(
            children: [
              CardHeader(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CardTitle(Text('Welcome back')),
                  CardDescription(Text('Sign in to your notebook')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final card = tester.getCenter(find.byType(Card)).dx;
    expect(
      tester.getCenter(find.text('Welcome back')).dx,
      moreOrLessEquals(card),
    );
    expect(
      tester.getCenter(find.text('Sign in to your notebook')).dx,
      moreOrLessEquals(card),
    );
    expect(
      tester
          .widget<RichText>(
            find.descendant(
              of: find.text('Welcome back'),
              matching: find.byType(RichText),
            ),
          )
          .textAlign,
      TextAlign.center,
    );
  });

  testWidgets('a footer can stack its children or wrap them', (tester) async {
    Widget footer(CardFooter footer) =>
        componentHost(SizedBox(width: 220, child: Card(children: [footer])));
    await tester.pumpWidget(
      footer(
        const CardFooter(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d8,
          children: [Text('Up 5.2%'), Text('Since January')],
        ),
      ),
    );
    final up = tester.getRect(find.text('Up 5.2%'));
    final since = tester.getRect(find.text('Since January'));
    expect(since.top - up.bottom, Spacing.d8);
    expect(since.left, up.left);
    await tester.pumpWidget(
      footer(
        const CardFooter(
          wrap: true,
          spacing: Spacing.d8,
          runSpacing: Spacing.d4,
          children: [
            SizedBox(key: Key('a'), width: 100, height: 20),
            SizedBox(key: Key('b'), width: 100, height: 20),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final a = tester.getRect(find.byKey(const Key('a')));
    final b = tester.getRect(find.byKey(const Key('b')));
    expect(b.top - a.bottom, Spacing.d4);
    expect(b.left, a.left);
  });
}
