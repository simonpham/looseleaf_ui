import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

class _Harness extends StatefulWidget {
  const _Harness({this.initial, this.disabledMiddle = false});

  final String? initial;
  final bool disabledMiddle;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late String? value = widget.initial;

  @override
  Widget build(BuildContext context) => FocusScope(
    autofocus: true,
    child: InkRadioGroup<String>(
      value: value,
      onChanged: (next) => setState(() => value = next),
      children: [
        const InkRadioGroupItem(value: 'a', label: Text('Alpha')),
        InkRadioGroupItem(
          value: 'b',
          disabled: widget.disabledMiddle,
          label: const Text('Bravo'),
        ),
        const InkRadioGroupItem(value: 'c', label: Text('Charlie')),
      ],
    ),
  );
}

Set<InkState> _states(WidgetTester tester, String label) => tester
    .widget<InkSurface>(
      find.descendant(
        of: find.widgetWithText(InkRadioGroupItem<String>, label),
        matching: find.byType(InkSurface),
      ),
    )
    .states;

bool _checked(WidgetTester tester, String label) =>
    _states(tester, label).contains(InkState.checked);

void main() {
  testWidgets('tapping an item or its label checks it', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    await tester.tap(find.text('Bravo'));
    await tester.pump();
    expect(_checked(tester, 'Bravo'), isTrue);
    expect(_checked(tester, 'Alpha'), isFalse);
  });

  testWidgets('Tab lands on the checked item, arrows move and check', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const _Harness(initial: 'b')));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_states(tester, 'Bravo'), contains(InkState.focused));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_checked(tester, 'Charlie'), isTrue);
    expect(_states(tester, 'Charlie'), contains(InkState.focused));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_checked(tester, 'Alpha'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(_checked(tester, 'Charlie'), isTrue);
  });

  testWidgets('arrows skip disabled items', (tester) async {
    await tester.pumpWidget(
      componentHost(const _Harness(initial: 'a', disabledMiddle: true)),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_checked(tester, 'Charlie'), isTrue);
  });

  testWidgets('Space checks the focused item', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(_checked(tester, 'Alpha'), isTrue);
  });

  testWidgets('gap and columnGap space the items', (tester) async {
    double gapBetween(String a, String b, {required bool vertical}) {
      final first = tester.getRect(
        find.byType(InkRadioGroupItem<String>).at(0),
      );
      final second = tester.getRect(
        find.byType(InkRadioGroupItem<String>).at(1),
      );
      return switch (vertical) {
        true => second.top - first.bottom,
        false => second.left - first.right,
      };
    }

    Widget group(Axis direction) => componentHost(
      InkRadioGroup<String>(
        value: 'a',
        direction: direction,
        gap: Spacing.d16,
        columnGap: Spacing.d28,
        children: const [
          InkRadioGroupItem(value: 'a', label: Text('Alpha')),
          InkRadioGroupItem(value: 'b', label: Text('Bravo')),
        ],
      ),
    );

    await tester.pumpWidget(group(Axis.vertical));
    expect(gapBetween('Alpha', 'Bravo', vertical: true), Spacing.d16);
    await tester.pumpWidget(group(Axis.horizontal));
    expect(gapBetween('Alpha', 'Bravo', vertical: false), Spacing.d28);
  });

  testWidgets('reads as a radio in a group', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const _Harness(initial: 'a')));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Alpha')),
      matchesSemantics(
        label: 'Alpha',
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('a disabled group disables every item', (tester) async {
    String? changed;
    await tester.pumpWidget(
      componentHost(
        InkRadioGroup<String>(
          value: null,
          disabled: true,
          onChanged: (value) => changed = value,
          children: const [InkRadioGroupItem(value: 'a', label: Text('Alpha'))],
        ),
      ),
    );
    await tester.tap(find.text('Alpha'), warnIfMissed: false);
    expect(changed, isNull);
    expect(_states(tester, 'Alpha'), {InkState.disabled});
  });

  testWidgets('the ring lines up with the title, the description is regular', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Align(
          alignment: Alignment.topLeft,
          child: InkRadioGroup<String>(
            value: 'a',
            children: [
              InkRadioGroupItem(
                value: 'a',
                size: Spacing.d20,
                label: Text('Studio'),
                description: Text('Ten notebooks'),
              ),
            ],
          ),
        ),
      ),
    );
    final ring = tester.getRect(find.byType(InkSurface));
    final title = tester.getRect(find.text('Studio'));
    expect(ring.center.dy, closeTo(title.center.dy, 0.5));
    final help = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text('Ten notebooks'),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(help.style.fontWeight, FontWeight.w400);
  });
}
