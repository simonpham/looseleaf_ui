import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

class _Harness extends StatefulWidget {
  const _Harness({this.initial = false, this.focusNode});

  final bool? initial;
  final FocusNode? focusNode;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late bool? value = widget.initial;

  @override
  Widget build(BuildContext context) => Checkbox(
    value: value,
    focusNode: widget.focusNode,
    onChanged: (next) => setState(() => value = next),
    label: const Text('Accept the terms'),
  );
}

Set<InkState> _states(WidgetTester tester) =>
    tester.widget<InkSurface>(find.byType(InkSurface)).states;

void main() {
  testWidgets('tapping the box or the label toggles it', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    expect(_states(tester), isNot(contains(InkState.checked)));
    await tester.tap(find.byType(InkSurface));
    await tester.pump();
    expect(_states(tester), contains(InkState.checked));
    await tester.tap(find.text('Accept the terms'));
    await tester.pump();
    expect(_states(tester), isNot(contains(InkState.checked)));
  });

  testWidgets('a tap in the hit slop toggles it', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    final box = tester.getRect(find.byType(InkSurface));
    await tester.tapAt(box.topLeft - const Offset(Spacing.d4, Spacing.d4));
    await tester.pump();
    expect(_states(tester), contains(InkState.checked));
  });

  testWidgets('indeterminate turns checked, then unchecked', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness(initial: null)));
    expect(_states(tester), contains(InkState.indeterminate));
    await tester.tap(find.byType(InkSurface));
    await tester.pump();
    expect(_states(tester), contains(InkState.checked));
    expect(_states(tester), isNot(contains(InkState.indeterminate)));
  });

  testWidgets('Space toggles, Enter is left alone', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(_Harness(focusNode: focusNode)),
    );
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_states(tester), isNot(contains(InkState.checked)));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(_states(tester), contains(InkState.checked));
  });

  testWidgets('draws on only once the user toggles it', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness(initial: true)));
    final surface = find.byType(InkSurface);
    expect(tester.widget<InkSurface>(surface).drawOn, isFalse);
    await tester.tap(surface);
    await tester.pump();
    expect(tester.widget<InkSurface>(surface).drawOn, isTrue);
  });

  testWidgets('reads as a labelled tri-state checkbox', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const _Harness(initial: null)));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Accept the terms')),
      matchesSemantics(
        label: 'Accept the terms',
        hasCheckedState: true,
        isCheckStateMixed: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('disabled ignores taps and shows invalid as a state', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      componentHost(
        Checkbox(
          value: false,
          disabled: true,
          invalid: true,
          onChanged: (_) => changes++,
        ),
      ),
    );
    await tester.tap(find.byType(InkSurface), warnIfMissed: false);
    expect(changes, 0);
    expect(_states(tester), {InkState.disabled, InkState.invalid});
  });
}
