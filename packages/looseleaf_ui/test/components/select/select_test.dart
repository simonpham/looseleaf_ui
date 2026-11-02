import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

const List<String> _fruits = ['Apple', 'Banana', 'Blueberry', 'Grapes'];

Widget _select({
  String? value,
  ValueChanged<String>? onChanged,
  ValueChanged<bool>? onOpenChange,
  SelectPosition position = SelectPosition.popper,
  bool disabled = false,
  Set<String> off = const {},
  String? defaultValue,
}) => SizedBox(
  width: 190,
  child: Select(
    value: value,
    defaultValue: defaultValue,
    onChanged: onChanged,
    onOpenChange: onOpenChange,
    disabled: disabled,
    content: SelectContent(
      position: position,
      seed: 'list',
      children: [
        SelectGroup(
          children: [
            const SelectLabel(Text('Fruits')),
            for (final fruit in _fruits)
              SelectItem(
                value: fruit.toLowerCase(),
                disabled: off.contains(fruit),
                child: Text(fruit),
              ),
          ],
        ),
      ],
    ),
    child: const SelectTrigger(
      seed: 'trigger',
      semanticLabel: 'Fruit',
      child: SelectValue(placeholder: 'Pick a fruit'),
    ),
  ),
);

void main() {
  testWidgets('a label focuses the trigger through its focusNode', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    final opens = <bool>[];
    await tester.pumpWidget(
      overlayHost(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Label(focusNode: node, child: const Text('Fruit')),
            SizedBox(
              width: 190,
              child: Select(
                onOpenChange: opens.add,
                content: const SelectContent(
                  children: [SelectItem(value: 'apple', child: Text('Apple'))],
                ),
                child: SelectTrigger(
                  focusNode: node,
                  child: const SelectValue(placeholder: 'Pick a fruit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Fruit'));
    await tester.pump();
    expect(node.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(opens, [true]);
  });

  testWidgets('shows the placeholder, opens on tap and chooses a row', (
    tester,
  ) async {
    final chosen = <String>[];
    final opens = <bool>[];
    await tester.pumpWidget(
      overlayHost(_select(onChanged: chosen.add, onOpenChange: opens.add)),
    );
    expect(find.text('Pick a fruit'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);
    await tester.tap(find.byType(SelectTrigger));
    await tester.pumpAndSettle();
    expect(find.text('Banana'), findsOneWidget);
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();
    expect(chosen, ['banana']);
    expect(opens, [true, false]);
    expect(find.text('Pick a fruit'), findsNothing);
    expect(find.text('Banana'), findsOneWidget);
  });

  testWidgets('a popper list opens 4 px under the trigger, as wide', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(_select()));
    await tester.tap(find.byType(SelectTrigger));
    await tester.pumpAndSettle();
    final trigger = tester.getRect(find.byType(SelectTrigger));
    final list = tester.getRect(find.byType(PaperPopup));
    expect(list.top - trigger.bottom, closeTo(SelectMetrics.popperOffset, 1));
    expect(list.width, greaterThanOrEqualTo(trigger.width));
  });

  testWidgets('an item-aligned list lays the chosen row over the trigger', (
    tester,
  ) async {
    await tester.pumpWidget(
      overlayHost(
        _select(
          position: SelectPosition.itemAligned,
          defaultValue: 'blueberry',
        ),
      ),
    );
    await tester.tap(find.byType(SelectTrigger));
    await tester.pumpAndSettle();
    final trigger = tester.getRect(find.byType(SelectTrigger));
    final row = tester.getRect(
      find.ancestor(
        of: find.text('Blueberry').last,
        matching: find.byType(SelectItem),
      ),
    );
    expect(row.center.dy, closeTo(trigger.center.dy, 1));
    final list = tester.getRect(find.byType(PaperPopup));
    expect(list.left, closeTo(trigger.left, 1));
  });

  testWidgets('item-aligned in right-to-left lines up with the right edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      overlayHost(
        Directionality(
          textDirection: TextDirection.rtl,
          child: _select(
            position: SelectPosition.itemAligned,
            defaultValue: 'apple',
          ),
        ),
      ),
    );
    await tester.tap(find.byType(SelectTrigger));
    await tester.pumpAndSettle();
    final trigger = tester.getRect(find.byType(SelectTrigger));
    final list = tester.getRect(find.byType(PaperPopup));
    expect(list.right, closeTo(trigger.right, 1));
    final row = tester.getRect(
      find.ancestor(
        of: find.text('Apple').last,
        matching: find.byType(SelectItem),
      ),
    );
    final tick = tester.getRect(find.byType(InkMarkWipe));
    expect(tick.center.dx, lessThan(row.center.dx));
  });

  testWidgets('keys open, move, choose and give focus back', (tester) async {
    final chosen = <String>[];
    await tester.pumpWidget(
      overlayHost(_select(onChanged: chosen.add, off: {'Banana'})),
    );
    Select.of(
      tester.element(find.byType(SelectValue)),
    ).triggerFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);
    SelectController controller() =>
        Select.of(tester.element(find.byType(SelectItem).first));
    expect(controller().highlighted, 'apple');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(controller().highlighted, 'blueberry');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(controller().highlighted, 'grapes');
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(controller().highlighted, 'apple');
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    await tester.pump();
    expect(controller().highlighted, 'grapes');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(chosen, ['grapes']);
    expect(find.byType(SelectItem), findsNothing);
    final trigger = Select.of(tester.element(find.byType(SelectValue)));
    expect(trigger.triggerFocus.hasFocus, isTrue);
  });

  testWidgets('Escape closes without choosing', (tester) async {
    final chosen = <String>[];
    await tester.pumpWidget(overlayHost(_select(onChanged: chosen.add)));
    await tester.tap(find.byType(SelectTrigger));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(SelectItem), findsNothing);
    expect(chosen, isEmpty);
  });

  testWidgets('letters on the closed trigger choose by typeahead', (
    tester,
  ) async {
    final chosen = <String>[];
    await tester.pumpWidget(overlayHost(_select(onChanged: chosen.add)));
    Select.of(
      tester.element(find.byType(SelectValue)),
    ).triggerFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.pump();
    expect(chosen, ['banana']);
    expect(find.byType(SelectItem), findsNothing);
  });

  testWidgets('disabled rows and a disabled select do nothing', (
    tester,
  ) async {
    final chosen = <String>[];
    await tester.pumpWidget(
      overlayHost(_select(onChanged: chosen.add, off: {'Banana'})),
    );
    await tester.tap(find.byType(SelectTrigger));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();
    expect(chosen, isEmpty);
    expect(find.text('Banana'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(overlayHost(_select(disabled: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SelectTrigger), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(SelectItem), findsNothing);
  });

  testWidgets('the trigger hands the open layer and invalid to the ink', (
    tester,
  ) async {
    await tester.pumpWidget(
      overlayHost(
        const Select(
          content: SelectContent(
            children: [SelectItem(value: 'a', child: Text('A'))],
          ),
          child: SelectTrigger(invalid: true, seed: 's'),
        ),
      ),
    );
    InkSurface surface() => tester.widget(
      find.descendant(
        of: find.byType(SelectTrigger),
        matching: find.byType(InkSurface),
      ),
    );
    expect(surface().states, contains(InkState.invalid));
    expect(surface().states, isNot(contains(InkState.open)));
    await tester.tap(find.byType(SelectTrigger));
    await tester.pumpAndSettle();
    expect(surface().states, contains(InkState.open));
  });

  testWidgets('trigger and rows speak to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(_select(value: 'apple')));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Fruit')),
      matchesSemantics(
        label: 'Fruit',
        value: 'Apple',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.byType(SelectTrigger));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Apple').last),
      matchesSemantics(
        label: 'Apple',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('trigger heights follow size and density', (tester) async {
    for (final (size, density, height) in [
      (SelectSize.regular, LooseleafDensity.comfortable, Spacing.d36),
      (SelectSize.sm, LooseleafDensity.comfortable, Spacing.d32),
      (SelectSize.regular, LooseleafDensity.compact, Spacing.d32),
      (SelectSize.sm, LooseleafDensity.calm, Spacing.d28),
    ]) {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        overlayHost(
          Select(
            content: const SelectContent(children: []),
            child: SelectTrigger(size: size, seed: 's'),
          ),
          theme: LooseleafThemeData(density: density),
        ),
      );
      expect(tester.getSize(find.byType(SelectTrigger)).height, height);
    }
  });

  test('placement keeps the row on the trigger and scrolls when tall', () {
    final fits = SelectPlacement.resolve(
      trigger: const Rect.fromLTWH(0, 200, 100, 36),
      bounds: const Size(400, 600),
      listHeight: 160,
      rowTop: 40,
      rowHeight: 32,
      margin: 10,
    );
    expect(fits.top, 200 + 18 - 56);
    expect(fits.height, 160);
    expect(fits.scroll, 0);
    final tall = SelectPlacement.resolve(
      trigger: const Rect.fromLTWH(0, 40, 100, 36),
      bounds: const Size(400, 300),
      listHeight: 900,
      rowTop: 600,
      rowHeight: 32,
      margin: 10,
    );
    expect(tall.height, 280);
    expect(tall.top, 10);
    expect(tall.scroll, 616 - (58 - 10));
  });
}
