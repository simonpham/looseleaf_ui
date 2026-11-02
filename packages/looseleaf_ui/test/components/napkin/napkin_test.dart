import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('is 288 wide and at least 224 tall, the footer at the foot', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Napkin(
          seed: 'n',
          children: [
            NapkinTitle(Text('Specials')),
            NapkinContent(Text('soup')),
            NapkinFooter(Text('until six')),
          ],
        ),
      ),
    );
    final napkin = tester.getRect(find.byType(Napkin));
    expect(napkin.size, const Size(288, 224));
    final title = tester.getTopLeft(find.text('Specials'));
    expect(title - napkin.topLeft, const Offset(36, 36));
    expect(tester.getBottomLeft(find.text('until six')).dy, napkin.bottom - 36);
  });

  testWidgets('grows past its least height with long notes', (tester) async {
    await tester.pumpWidget(
      componentHost(
        Napkin(
          seed: 'n',
          children: [NapkinContent(Text('word ' * 60))],
        ),
      ),
    );
    expect(tester.getSize(find.byType(Napkin)).height, greaterThan(224));
  });

  testWidgets('draws the creases only when folded or stained', (tester) async {
    await tester.pumpWidget(
      componentHost(const Napkin(fold: NapkinFold.none, seed: 'n')),
    );
    expect(_decor(tester), isEmpty);
    await tester.pumpWidget(componentHost(const Napkin(seed: 'n')));
    expect(_decor(tester).single.seed, 'n|decor');
    await tester.pumpWidget(
      componentHost(const Napkin(fold: NapkinFold.none, stain: true)),
    );
    expect(_decor(tester), hasLength(1));
  });

  testWidgets('sits on the napkin stock without rules', (tester) async {
    await tester.pumpWidget(componentHost(const Napkin(seed: 'n')));
    final paper = tester.widget<Paper>(find.byType(Paper));
    expect(paper.stock, StockName.napkin);
    expect(paper.rules, RuleName.none);
    expect(paper.tiltDegrees?.abs(), lessThanOrEqualTo(1.2));
  });

  testWidgets('the title is a header', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const Napkin(children: [NapkinTitle(Text('Specials'))])),
    );
    expect(
      tester.getSemantics(find.byType(NapkinTitle)),
      matchesSemantics(label: 'Specials', isHeader: true),
    );
    handle.dispose();
  });

  testWidgets('a least height of 0 with custom padding fits the note', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Napkin(
          minHeight: 0,
          padding: EdgeInsets.all(28),
          children: [NapkinContent(Text('404'))],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final napkin = tester.getRect(find.byType(Napkin));
    expect(napkin.height, lessThan(Napkin.defaultMinHeight));
    expect(
      tester.getTopLeft(find.text('404')) - napkin.topLeft,
      const Offset(28, 28),
    );
  });

  testWidgets('the content can centre its note', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Napkin(
          children: [NapkinContent(Text('404'), alignment: Alignment.center)],
        ),
      ),
    );
    final napkin = tester.getRect(find.byType(Napkin));
    final note = tester.getCenter(find.text('404'));
    expect(note.dx, moreOrLessEquals(napkin.center.dx, epsilon: 1));
    expect(note.dy, moreOrLessEquals(napkin.center.dy, epsilon: 1));
  });
}

List<InkSurface> _decor(WidgetTester tester) => tester
    .widgetList<InkSurface>(find.byType(InkSurface))
    .where((surface) => surface.seed.endsWith('|decor'))
    .toList();
