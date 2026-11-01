import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/overlay_host.dart';

Button _outline(String label, {VoidCallback? onPressed, FocusNode? focus}) =>
    Button(
      variant: ButtonVariant.outline,
      seed: label,
      focusNode: focus,
      onPressed: onPressed,
      child: Text(label),
    );

List<ButtonGroupSeam> _seams(WidgetTester tester) =>
    tester.widgetList<ButtonGroupSeam>(find.byType(ButtonGroupSeam)).toList();

void main() {
  testWidgets('members share seams: every one after the first is cut', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        ButtonGroup(
          children: [_outline('Years'), _outline('Months'), _outline('Days')],
        ),
      ),
    );
    expect(
      [for (final seam in _seams(tester)) seam.clipStart],
      [
        false,
        true,
        true,
      ],
    );
    expect(
      [for (final seam in _seams(tester)) seam.clipEnd],
      [
        false,
        false,
        false,
      ],
    );
    final years = tester.getTopRight(find.byType(Button).at(0));
    final months = tester.getTopLeft(find.byType(Button).at(1));
    expect(years, months);
  });

  testWidgets('a member before a separator is cut at its end', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        ButtonGroup(
          children: [
            Button(onPressed: () {}, child: const Text('Save')),
            const ButtonGroupSeparator(),
            Button(onPressed: () {}, child: const Text('More')),
          ],
        ),
      ),
    );
    final seams = _seams(tester);
    expect(seams.first.clipEnd, isTrue);
    expect(seams.last.clipStart, isTrue);
    final separator = tester.getSize(find.byType(ButtonGroupSeparator));
    expect(separator.height, tester.getSize(find.byType(Button).first).height);
  });

  testWidgets('a focused member is drawn whole', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      componentHost(
        ButtonGroup(
          children: [
            _outline('A'),
            _outline('B', focus: focus),
          ],
        ),
      ),
    );
    ClipRect clipOf(int index) => tester.widget<ClipRect>(
      find
          .descendant(
            of: find.byType(ButtonGroupSeam).at(index),
            matching: find.byType(ClipRect),
          )
          .first,
    );
    expect(clipOf(1).clipBehavior, Clip.hardEdge);
    expect(clipOf(0).clipBehavior, Clip.none);
    focus.requestFocus();
    await tester.pump();
    await tester.pump();
    expect(clipOf(1).clipBehavior, Clip.none);
  });

  testWidgets('members still work and Tab walks through them', (
    tester,
  ) async {
    final pressed = <String>[];
    final first = FocusNode();
    addTearDown(first.dispose);
    await tester.pumpWidget(
      componentHost(
        ButtonGroup(
          children: [
            _outline('A', focus: first, onPressed: () => pressed.add('A')),
            _outline('B', onPressed: () => pressed.add('B')),
          ],
        ),
      ),
    );
    await tester.tap(find.text('A'));
    first.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(pressed, ['A', 'B']);
  });

  testWidgets('nested groups sit 8 px apart; an Expanded input fills', (
    tester,
  ) async {
    await tester.pumpWidget(
      overlayHost(
        SizedBox(
          width: 400,
          child: ButtonGroup(
            children: [
              const ButtonGroupText(child: Text('https://')),
              const Expanded(child: Input(placeholder: 'example.com')),
              Button(onPressed: () {}, child: const Text('Go')),
            ],
          ),
        ),
      ),
    );
    final row = tester.getSize(find.byType(ButtonGroup));
    expect(row.width, 400);
    await tester.pumpWidget(
      componentHost(
        ButtonGroup(
          children: [
            ButtonGroup(children: [_outline('1'), _outline('2')]),
            ButtonGroup(children: [_outline('3')]),
          ],
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('3')).dx -
          tester.getTopRight(find.byType(Button).at(1)).dx,
      greaterThanOrEqualTo(8),
    );
    expect(
      tester.getTopLeft(find.byType(Button).at(2)).dx -
          tester.getTopRight(find.byType(Button).at(1)).dx,
      8,
    );
  });

  testWidgets('a text cell follows the button heights per density', (
    tester,
  ) async {
    for (final (density, height) in [
      (LooseleafDensity.comfortable, 36.0),
      (LooseleafDensity.compact, 32.0),
      (LooseleafDensity.calm, 28.0),
    ]) {
      await tester.pumpWidget(
        componentHost(
          const ButtonGroupText(child: Text('grams')),
          theme: LooseleafThemeData(density: density),
        ),
      );
      expect(tester.getSize(find.byType(InkSurface)).height, height);
    }
  });

  testWidgets('the group carries its label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        ButtonGroup(semanticLabel: 'Range', children: [_outline('Years')]),
      ),
    );
    expect(find.bySemanticsLabel('Range'), findsOneWidget);
    handle.dispose();
  });
}
