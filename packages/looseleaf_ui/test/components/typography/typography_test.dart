import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

TextStyle? _style(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style;

void main() {
  const colors = LooseleafColors();

  testWidgets('each role takes its face, size and color', (tester) async {
    for (final (widget, text, size, color, weight) in [
      (
        const H1(child: Text('h1')),
        'h1',
        48 * 0.75,
        colors.ink,
        FontWeight.w700,
      ),
      (
        const H2(child: Text('h2')),
        'h2',
        36 * 0.75,
        colors.ink,
        FontWeight.w700,
      ),
      (
        const H3(child: Text('h3')),
        'h3',
        30 * 0.75,
        colors.ink,
        FontWeight.w700,
      ),
      (
        const H4(child: Text('h4')),
        'h4',
        20 * 0.88,
        colors.ink,
        FontWeight.w700,
      ),
      (const P(child: Text('p')), 'p', 17 * 0.88, colors.ink, FontWeight.w400),
      (
        const Lead(child: Text('lead')),
        'lead',
        20 * 0.88,
        colors.inkMuted,
        FontWeight.w400,
      ),
      (
        const Muted(child: Text('muted')),
        'muted',
        14 * 0.88,
        colors.inkMuted,
        FontWeight.w400,
      ),
      (
        const Small(child: Text('small')),
        'small',
        14 * 0.88,
        colors.ink,
        FontWeight.w700,
      ),
      (
        const Blockquote(child: Text('quote')),
        'quote',
        24 * 0.75,
        colors.inkSoft,
        FontWeight.w400,
      ),
    ]) {
      await tester.pumpWidget(componentHost(widget));
      final style = _style(tester, text);
      expect(style?.fontSize, closeTo(size, 0.001), reason: text);
      expect(style?.color, color, reason: text);
      expect(style?.fontWeight, weight, reason: text);
    }
  });

  testWidgets('headings are headers; H1 and H2 carry a rule', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const H2(child: Text('Section'))));
    expect(find.byType(HeadingRule), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Section')),
      matchesSemantics(label: 'Section', isHeader: true),
    );
    await tester.pumpWidget(
      componentHost(const H1(rule: false, child: Text('Title'))),
    );
    expect(find.byType(HeadingRule), findsNothing);
    handle.dispose();
  });

  testWidgets('the blockquote picks one of three bars by seed', (
    tester,
  ) async {
    for (var index = 0; index < 3; index++) {
      expect(
        QuoteBarPainter.document(index).layers['rest']?.children,
        isNotEmpty,
      );
    }
    await tester.pumpWidget(
      componentHost(const Blockquote(seed: 'q', child: Text('quote'))),
    );
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(Blockquote),
        matching: find.byType(CustomPaint),
      ),
    );
    expect((paint.painter as QuoteBarPainter).index, hashSeed('q') % 3);
    expect(
      tester.getTopLeft(find.text('quote')).dx -
          tester.getTopLeft(find.byType(Blockquote)).dx,
      20,
    );
  });

  testWidgets('lists number or bullet their items', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: TypographyList(
            ordered: true,
            children: [Text('one'), Text('two')],
          ),
        ),
      ),
    );
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(_style(tester, '1.')?.color, colors.marker);
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: TypographyList(children: [Text('one')]),
        ),
      ),
    );
    expect(find.text('1.'), findsNothing);
  });

  testWidgets('prose caps its width at 64 characters', (tester) async {
    await tester.pumpWidget(
      componentHost(const Prose(children: [Text('wide')])),
    );
    expect(tester.getSize(find.byType(Prose)).width, 17 * 32);
  });

  testWidgets('inline code is set in the bundled IBM Plex Mono', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const InlineCode('npm run notes')));
    final style = _style(tester, 'npm run notes');
    expect(style?.fontFamily, 'packages/looseleaf_ui/IBMPlexMono');
    expect(style?.fontSize, closeTo(17 * 0.88 * 0.85, 0.001));
  });
}
