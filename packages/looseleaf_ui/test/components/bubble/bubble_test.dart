import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _host(Widget child) => componentHost(SizedBox(width: 400, child: child));

InkSurface _surface(WidgetTester tester, String text) => tester.widget(
  find.ancestor(of: find.text(text), matching: find.byType(InkSurface)).first,
);

void main() {
  testWidgets('draws the cloud with the tail on the bubble side', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Bubble(
          align: ChatAlign.end,
          variant: BubbleVariant.muted,
          children: [BubbleContent(seed: 'a', child: Text('hi'))],
        ),
      ),
    );
    final source = _surface(tester, 'hi').source as RecipeInkSource;
    final params = source.params as BubbleParams;
    expect(params.tail, BubbleTail.end);
    expect(params.variant, BubbleVariant.muted);
    expect(params.interactive, isFalse);
    final right = tester.getTopRight(find.byType(InkSurface)).dx;
    expect(right, tester.getTopRight(find.byType(SizedBox).first).dx);
  });

  testWidgets('takes the side of the enclosing message', (tester) async {
    await tester.pumpWidget(
      _host(
        const ChatAlignScope(
          align: ChatAlign.end,
          child: Bubble(children: [BubbleContent(child: Text('hi'))]),
        ),
      ),
    );
    final source = _surface(tester, 'hi').source as RecipeInkSource;
    expect((source.params as BubbleParams).tail, BubbleTail.end);
  });

  testWidgets('a group hides every tail but the last', (tester) async {
    await tester.pumpWidget(
      _host(
        const BubbleGroup(
          children: [
            Bubble(children: [BubbleContent(child: Text('one'))]),
            Bubble(children: [BubbleContent(child: Text('two'))]),
          ],
        ),
      ),
    );
    expect(_surface(tester, 'one').source, isA<WithoutPartInkSource>());
    expect(_surface(tester, 'two').source, isA<RecipeInkSource>());
  });

  testWidgets('tail: false hides the tail', (tester) async {
    await tester.pumpWidget(
      _host(
        const Bubble(tail: false, children: [BubbleContent(child: Text('x'))]),
      ),
    );
    expect(_surface(tester, 'x').source, isA<WithoutPartInkSource>());
  });

  testWidgets('takes at most 80 % of the row, ghosts all of it', (
    tester,
  ) async {
    const long = 'word word word word word word word word word word word word';
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            Bubble(children: [BubbleContent(child: Text(long))]),
            Bubble(
              variant: BubbleVariant.ghost,
              children: [BubbleContent(child: Text('$long.'))],
            ),
          ],
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(InkSurface)).width,
      lessThanOrEqualTo(320),
    );
    expect(find.byType(InkSurface), findsOneWidget);
    expect(tester.getSize(find.text('$long.')).width, greaterThan(320));
  });

  testWidgets('pads by density', (tester) async {
    for (final (density, padding) in const [
      (LooseleafDensity.comfortable, (16.0, 10.0)),
      (LooseleafDensity.compact, (14.0, 8.0)),
      (LooseleafDensity.calm, (12.0, 6.0)),
    ]) {
      await tester.pumpWidget(
        componentHost(
          const Bubble(children: [BubbleContent(child: Text('hi'))]),
          theme: LooseleafThemeData(density: density),
        ),
      );
      final surface = tester.getRect(find.byType(InkSurface));
      final text = tester.getRect(find.text('hi'));
      expect(text.left - surface.left, padding.$1);
      expect(text.top - surface.top, padding.$2);
    }
  });

  testWidgets('a pressable bubble is a button', (tester) async {
    var pressed = 0;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      _host(
        Bubble(
          children: [
            BubbleContent(
              focusNode: focus,
              onPressed: () => pressed++,
              child: const Text('Run the tests'),
            ),
          ],
        ),
      ),
    );
    final source = _surface(tester, 'Run the tests').source as RecipeInkSource;
    expect((source.params as BubbleParams).interactive, isTrue);
    await tester.tap(find.text('Run the tests'));
    expect(pressed, 1);
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(pressed, 2);
    expect(
      tester.getSemantics(find.byType(BubbleContent)),
      matchesSemantics(
        isButton: true,
        isFocusable: true,
        isFocused: true,
        hasTapAction: true,
        hasFocusAction: true,
        hasEnabledState: true,
        isEnabled: true,
        label: 'Run the tests',
      ),
    );
  });

  testWidgets('notes and stickies are paper', (tester) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            Bubble(
              shape: BubbleShape.note,
              children: [BubbleContent(child: Text('note'))],
            ),
            Bubble(
              shape: BubbleShape.sticky,
              variant: BubbleVariant.tinted,
              children: [BubbleContent(child: Text('sticky'))],
            ),
          ],
        ),
      ),
    );
    final papers = tester.widgetList<Paper>(find.byType(Paper)).toList();
    expect(papers.map((paper) => paper.stock), [
      StockName.slip,
      StockName.stickyPink,
    ]);
    expect(papers.first.decor, isA<BubbleCreases>());
    expect(papers.last.decor, isNull);
  });

  testWidgets('reactions hang off the bubble edge', (tester) async {
    await tester.pumpWidget(
      _host(
        const Bubble(
          children: [
            BubbleContent(child: Text('hello there')),
            BubbleReactions(child: Text('+1')),
          ],
        ),
      ),
    );
    final bubble = tester.getRect(find.byType(InkSurface).first);
    final chip = tester.getRect(find.byType(BubbleReactions));
    expect(chip.right, closeTo(bubble.right - 12, 0.01));
    expect(chip.top, closeTo(bubble.bottom - chip.height / 4, 0.01));
  });

  testWidgets('flips the side in right-to-left', (tester) async {
    await tester.pumpWidget(
      _host(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Bubble(children: [BubbleContent(child: Text('hi'))]),
        ),
      ),
    );
    final row = tester.getRect(find.byType(Bubble));
    expect(tester.getRect(find.byType(InkSurface)).right, row.right);
  });
}
