import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide RadioGroup;
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
    child: RadioGroup<String>(
      value: value,
      onChanged: (next) => setState(() => value = next),
      children: [
        const RadioGroupItem(value: 'a', label: Text('Alpha')),
        RadioGroupItem(
          value: 'b',
          disabled: widget.disabledMiddle,
          label: const Text('Bravo'),
        ),
        const RadioGroupItem(value: 'c', label: Text('Charlie')),
      ],
    ),
  );
}

Set<InkState> _states(WidgetTester tester, String label) => tester
    .widget<InkSurface>(
      find.descendant(
        of: find.widgetWithText(RadioGroupItem<String>, label),
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

  testWidgets('reads as a radio in a group', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const _Harness(initial: 'a')));
    expect(
      tester.getSemantics(find.widgetWithText(RadioGroupItem<String>, 'Alpha')),
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
        RadioGroup<String>(
          value: null,
          disabled: true,
          onChanged: (value) => changed = value,
          children: const [RadioGroupItem(value: 'a', label: Text('Alpha'))],
        ),
      ),
    );
    await tester.tap(find.text('Alpha'), warnIfMissed: false);
    expect(changed, isNull);
    expect(_states(tester, 'Alpha'), {InkState.disabled});
  });
}
