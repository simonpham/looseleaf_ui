import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _card({
  bool? flipped,
  ValueChanged<bool>? onFlippedChange,
  bool trigger = true,
  List<Widget> extra = const [],
}) => componentHost(
  FlipCard(
    flipped: flipped,
    onFlippedChange: onFlippedChange,
    trigger: trigger,
    label: 'Show the answer',
    children: [
      const FlipCardFront(children: [Text('le chat')]),
      const FlipCardBack(children: [Text('the cat')]),
      ...extra,
    ],
  ),
);

bool _shown(WidgetTester tester, String text) => tester
    .widget<Visibility>(
      find.ancestor(of: find.text(text), matching: find.byType(Visibility)),
    )
    .visible;

void main() {
  testWidgets('is 288 x 192 with an index card in front and a slip behind', (
    tester,
  ) async {
    await tester.pumpWidget(_card());
    expect(tester.getSize(find.byType(FlipCard)), const Size(288, 192));
    final papers = tester.widgetList<Paper>(find.byType(Paper)).toList();
    expect(papers.map((paper) => paper.stock), [
      StockName.indexCard,
      StockName.slip,
    ]);
    expect(papers.every((paper) => !paper.tilt), isTrue);
  });

  testWidgets('tapping turns it over and back', (tester) async {
    await tester.pumpWidget(_card());
    expect(_shown(tester, 'le chat'), isTrue);
    expect(_shown(tester, 'the cat'), isFalse);
    await tester.tap(find.byType(FlipCardTrigger));
    await tester.pumpAndSettle();
    expect(_shown(tester, 'le chat'), isFalse);
    expect(_shown(tester, 'the cat'), isTrue);
    await tester.tap(find.byType(FlipCardTrigger));
    await tester.pumpAndSettle();
    expect(_shown(tester, 'le chat'), isTrue);
  });

  testWidgets('Space and Enter turn it', (tester) async {
    final flips = <bool>[];
    await tester.pumpWidget(
      _card(
        onFlippedChange: flips.add,
        extra: const [
          Focus(autofocus: true, child: SizedBox.square(dimension: 8)),
        ],
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(flips, [true, false]);
  });

  testWidgets('a controlled card follows flipped', (tester) async {
    final flips = <bool>[];
    await tester.pumpWidget(_card(flipped: false, onFlippedChange: flips.add));
    await tester.tap(find.byType(FlipCardTrigger));
    await tester.pumpAndSettle();
    expect(flips, [true]);
    expect(_shown(tester, 'le chat'), isTrue);
    await tester.pumpWidget(_card(flipped: true, onFlippedChange: flips.add));
    await tester.pumpAndSettle();
    expect(_shown(tester, 'the cat'), isTrue);
  });

  testWidgets('the hidden face is out of the semantics tree', (tester) async {
    await tester.pumpWidget(_card(trigger: false));
    expect(find.bySemanticsLabel('le chat'), findsOneWidget);
    expect(find.bySemanticsLabel('the cat'), findsNothing);
  });

  testWidgets('the trigger is a pressed-state button named by label', (
    tester,
  ) async {
    await tester.pumpWidget(_card(flipped: true));
    expect(
      tester.getSemantics(find.byType(FlipCardTrigger)),
      matchesSemantics(
        label: 'Show the answer',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasToggledState: true,
        isToggled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });

  testWidgets('trigger: false leaves the faces free; a builder trigger turns', (
    tester,
  ) async {
    await tester.pumpWidget(
      _card(
        trigger: false,
        extra: [
          Positioned(
            right: 0,
            bottom: 0,
            child: FlipCardTrigger(
              overlay: false,
              builder: (context, toggle) => GestureDetector(
                onTap: toggle,
                child: const Text('Details'),
              ),
            ),
          ),
        ],
      ),
    );
    expect(find.byType(InkSurface), findsNothing);
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(_shown(tester, 'the cat'), isTrue);
  });

  testWidgets('reduced motion swaps at once', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const FlipCard(
          children: [
            FlipCardFront(children: [Text('front')]),
            FlipCardBack(children: [Text('back')]),
          ],
        ),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    await tester.tap(find.byType(FlipCardTrigger));
    await tester.pump();
    await tester.pump();
    expect(_shown(tester, 'back'), isTrue);
  });
}
