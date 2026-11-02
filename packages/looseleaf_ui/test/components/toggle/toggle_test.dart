import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

class _Harness extends StatefulWidget {
  const _Harness({this.focusNode});

  final FocusNode? focusNode;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  bool value = false;

  @override
  Widget build(BuildContext context) => Toggle(
    value: value,
    focusNode: widget.focusNode,
    semanticLabel: 'Bold',
    onChanged: (next) => setState(() => value = next),
    child: const Text('B'),
  );
}

Set<InkState> _states(WidgetTester tester) =>
    tester.widget<InkSurface>(find.byType(InkSurface)).states;

void main() {
  testWidgets('tapping presses it on and off', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    await tester.tap(find.byType(Toggle));
    await tester.pump();
    expect(_states(tester), contains(InkState.checked));
    await tester.tap(find.byType(Toggle));
    await tester.pump();
    expect(_states(tester), isNot(contains(InkState.checked)));
  });

  testWidgets('without a value it keeps its own, from defaultValue', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      componentHost(
        Toggle(
          defaultValue: true,
          onChanged: changes.add,
          child: const Text('B'),
        ),
      ),
    );
    expect(_states(tester), contains(InkState.checked));
    await tester.tap(find.byType(Toggle));
    await tester.pump();
    expect(_states(tester), isNot(contains(InkState.checked)));
    await tester.tap(find.byType(Toggle));
    await tester.pump();
    expect(_states(tester), contains(InkState.checked));
    expect(changes, [false, true]);
  });

  testWidgets('Enter and Space press it', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(componentHost(_Harness(focusNode: focusNode)));
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_states(tester), contains(InkState.checked));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(_states(tester), isNot(contains(InkState.checked)));
  });

  testWidgets('sizes follow size and density', (tester) async {
    for (final (size, density, height) in [
      (ToggleSize.regular, LooseleafDensity.comfortable, 36.0),
      (ToggleSize.regular, LooseleafDensity.compact, 32.0),
      (ToggleSize.sm, LooseleafDensity.comfortable, 32.0),
      (ToggleSize.lg, LooseleafDensity.comfortable, 40.0),
      (ToggleSize.lg, LooseleafDensity.calm, 32.0),
    ]) {
      await tester.pumpWidget(
        componentHost(
          Toggle(value: false, size: size, child: const SizedBox.shrink()),
          theme: LooseleafThemeData(density: density),
        ),
      );
      expect(tester.getSize(find.byType(Toggle)), Size(height, height));
    }
  });

  testWidgets('reads as a toggle button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const _Harness()));
    expect(
      tester.getSemantics(find.byType(Toggle)),
      matchesSemantics(
        label: 'Bold\nB',
        isButton: true,
        hasToggledState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('disabled ignores taps', (tester) async {
    var changes = 0;
    await tester.pumpWidget(
      componentHost(
        Toggle(
          value: false,
          disabled: true,
          onChanged: (_) => changes++,
          child: const Text('B'),
        ),
      ),
    );
    await tester.tap(find.byType(Toggle), warnIfMissed: false);
    expect(changes, 0);
  });
}
