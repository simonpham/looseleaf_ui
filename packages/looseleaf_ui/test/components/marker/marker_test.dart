import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

List<MarkerRuleParams> _rules(WidgetTester tester) => [
  for (final surface in tester.widgetList<InkSurface>(find.byType(InkSurface)))
    (surface.source as RecipeInkSource<MarkerRuleParams>).params,
];

void main() {
  testWidgets('a separator rules both sides in script', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 400,
          child: Marker(
            variant: MarkerVariant.separator,
            seed: 'day',
            children: [MarkerContent(child: Text('Today'))],
          ),
        ),
      ),
    );
    expect(_rules(tester).map((p) => p.side), [
      MarkerSide.start,
      MarkerSide.end,
    ]);
    final seeds = tester
        .widgetList<InkSurface>(find.byType(InkSurface))
        .map((s) => s.seed);
    expect(seeds, ['day|start', 'day|end']);
    final style = DefaultTextStyle.of(tester.element(find.text('Today'))).style;
    expect(style.fontSize, closeTo(20 * KevinSansFace.script.sizeAdjust, 1e-9));
    expect(tester.getSize(find.byType(InkSurface).first).height, Spacing.d16);
  });

  testWidgets('a border draws one wavy rule under the row', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: Marker(
            variant: MarkerVariant.border,
            tone: MarkerTone.fresh,
            rule: MarkerStyle.wavy,
            children: [MarkerContent(child: Text('3 unread'))],
          ),
        ),
      ),
    );
    final rule = _rules(tester).single;
    expect(rule.side, MarkerSide.full);
    expect(rule.style, MarkerStyle.wavy);
    expect(rule.tone, MarkerTone.fresh);
    expect(tester.getSize(find.byType(InkSurface)).width, 300);
  });

  testWidgets('the default is muted small print with an icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Marker(
          tone: MarkerTone.fresh,
          children: [
            MarkerIcon(child: Text('+')),
            MarkerContent(child: Text('Lin joined')),
          ],
        ),
      ),
    );
    expect(find.byType(InkSurface), findsNothing);
    const colors = LooseleafColors();
    final style = DefaultTextStyle.of(
      tester.element(find.text('Lin joined')),
    ).style;
    expect(style.fontWeight, FontWeight.w700);
    expect(
      IconTheme.of(tester.element(find.text('+'))).color,
      colors.red,
    );
    expect(tester.getSize(find.byType(MarkerIcon)), const Size.square(16));
  });

  testWidgets('with onPressed it is a button', (tester) async {
    final handle = tester.ensureSemantics();
    var pressed = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(
        Marker(
          variant: MarkerVariant.separator,
          onPressed: () => pressed++,
          focusNode: focusNode,
          semanticLabel: 'Mark as read',
          children: const [MarkerContent(child: Text('New messages'))],
        ),
      ),
    );
    await tester.tap(find.text('New messages'));
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(pressed, 2);
    expect(
      tester.getSemantics(find.byType(Marker)),
      matchesSemantics(
        isButton: true,
        label: 'Mark as read\nNew messages',
        isFocusable: true,
        isFocused: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });
}
