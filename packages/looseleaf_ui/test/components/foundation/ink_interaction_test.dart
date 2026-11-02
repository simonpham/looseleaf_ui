import 'package:flutter/semantics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

class _Probe {
  Set<InkState> states = const {};
  int activations = 0;
}

Widget _target(
  _Probe probe, {
  bool enabled = true,
  InkActivation activation = InkActivation.button,
  FocusNode? focusNode,
  EdgeInsets hitSlop = EdgeInsets.zero,
  SemanticsProperties? semantics,
}) => InkInteraction(
  semantics: semantics,
  enabled: enabled,
  activation: activation,
  focusNode: focusNode,
  hitSlop: hitSlop,
  states: const {InkState.checked},
  onActivate: () => probe.activations++,
  builder: (context, states) {
    probe.states = states;
    return const SizedBox.square(dimension: Spacing.d40);
  },
);

void main() {
  testWidgets('merges its own states with hover and press', (tester) async {
    final probe = _Probe();
    await tester.pumpWidget(componentHost(_target(probe)));
    expect(probe.states, {InkState.checked});

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(SizedBox).last));
    await tester.pump();
    expect(probe.states, {InkState.checked, InkState.hovered});

    await mouse.down(tester.getCenter(find.byType(SizedBox).last));
    await tester.pump();
    expect(probe.states, contains(InkState.pressed));
    await mouse.up();
    await tester.pump();
    expect(probe.states, isNot(contains(InkState.pressed)));
    expect(probe.activations, 1);
    await mouse.removePointer();
  });

  testWidgets('shows focus only for keyboard focus', (tester) async {
    final probe = _Probe();
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(_target(probe, focusNode: focusNode)),
    );

    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch;
    focusNode.requestFocus();
    await tester.pump();
    expect(probe.states, isNot(contains(InkState.focused)));

    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    await tester.pump();
    expect(probe.states, contains(InkState.focused));
    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.automatic;
  });

  testWidgets('a button activates on Enter and Space', (tester) async {
    final probe = _Probe();
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(_target(probe, focusNode: focusNode)),
    );
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(probe.activations, 2);
  });

  testWidgets('a toggle activates on Space only', (tester) async {
    final probe = _Probe();
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(
        _target(
          probe,
          activation: InkActivation.toggle,
          focusNode: focusNode,
        ),
      ),
    );
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(probe.activations, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(probe.activations, 1);
  });

  testWidgets('disabled drops input and focus', (tester) async {
    final probe = _Probe();
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(_target(probe, enabled: false, focusNode: focusNode)),
    );
    expect(probe.states, {InkState.checked, InkState.disabled});
    await tester.tap(find.byType(SizedBox).last, warnIfMissed: false);
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
    expect(probe.activations, 0);
  });

  testWidgets('the hit slop reaches past the box', (tester) async {
    final probe = _Probe();
    await tester.pumpWidget(
      componentHost(
        _target(probe, hitSlop: const EdgeInsets.all(Spacing.d6)),
      ),
    );
    final box = tester.getRect(find.byType(SizedBox).last);
    await tester.tapAt(box.topLeft - const Offset(Spacing.d4, Spacing.d4));
    expect(probe.activations, 1);
    await tester.tapAt(box.topLeft - const Offset(Spacing.d8, Spacing.d8));
    expect(probe.activations, 1);
  });

  testWidgets('the hit slop reaches past its own semantics node', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final probe = _Probe();
    await tester.pumpWidget(
      componentHost(
        _target(
          probe,
          hitSlop: const EdgeInsets.all(Spacing.d6),
          semantics: const SemanticsProperties(button: true, label: 'Probe'),
        ),
      ),
    );
    final box = tester.getRect(find.byType(SizedBox).last);
    await tester.tapAt(box.bottomRight + const Offset(Spacing.d4, Spacing.d4));
    expect(probe.activations, 1);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Probe')),
      matchesSemantics(
        label: 'Probe',
        isButton: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  test('ByDensity resolves each density', () {
    const height = ByDensity(comfortable: 36.0, compact: 32.0, calm: 28.0);
    expect(height.resolve(LooseleafDensity.comfortable), 36);
    expect(height.resolve(LooseleafDensity.compact), 32);
    expect(height.resolve(LooseleafDensity.calm), 28);
  });
}
