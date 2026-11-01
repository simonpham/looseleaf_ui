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
  Widget build(BuildContext context) => Switch(
    value: value,
    focusNode: widget.focusNode,
    onChanged: (next) => setState(() => value = next),
    label: const Text('Airplane mode'),
  );
}

Set<InkState> _states(WidgetTester tester) =>
    tester.widget<InkSurface>(find.byType(InkSurface).first).states;

void main() {
  testWidgets('tapping the track or the label toggles it', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    await tester.tap(find.byType(InkSurface).first);
    await tester.pump();
    expect(_states(tester), contains(InkState.checked));
    await tester.tap(find.text('Airplane mode'));
    await tester.pump();
    expect(_states(tester), isNot(contains(InkState.checked)));
  });

  testWidgets('Space toggles, Enter is left alone', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(componentHost(_Harness(focusNode: focusNode)));
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_states(tester), isNot(contains(InkState.checked)));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(_states(tester), contains(InkState.checked));
  });

  testWidgets('the thumb moves to the end when on', (tester) async {
    await tester.pumpWidget(
      componentHost(const Switch(value: false, seed: 's')),
    );
    final track = tester.getRect(find.byType(InkSurface).first);
    expect(tester.getRect(find.byType(InkSurface).last).left, track.left + 4);
    await tester.pumpWidget(
      componentHost(const Switch(value: true, seed: 's')),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(InkSurface).last).left, track.left + 24);
  });

  testWidgets('sizes follow size and calm density', (tester) async {
    await tester.pumpWidget(componentHost(const Switch(value: false)));
    expect(tester.getSize(find.byType(Switch)), const Size(44, 24));
    await tester.pumpWidget(
      componentHost(const Switch(value: false, size: SwitchSize.sm)),
    );
    expect(tester.getSize(find.byType(Switch)), const Size(36, 20));
    await tester.pumpWidget(
      componentHost(
        const Switch(value: false),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(tester.getSize(find.byType(Switch)), const Size(36, 20));
  });

  testWidgets('reads as a labelled toggle', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const _Harness()));
    expect(
      tester.getSemantics(find.byType(Switch)),
      matchesSemantics(
        label: 'Airplane mode',
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
        Switch(value: false, disabled: true, onChanged: (_) => changes++),
      ),
    );
    await tester.tap(find.byType(Switch), warnIfMissed: false);
    expect(changes, 0);
    expect(_states(tester), {InkState.disabled});
  });
}
