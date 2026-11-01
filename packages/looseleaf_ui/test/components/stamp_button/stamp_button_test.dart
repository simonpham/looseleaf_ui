import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _page({
  List<StampImpression>? value,
  ValueChanged<List<StampImpression>>? onValueChanged,
  FocusNode? focusNode,
  bool disabled = false,
}) => StampSurface(
  value: value,
  onValueChanged: onValueChanged,
  child: SizedBox(
    width: 400,
    height: 300,
    child: Align(
      alignment: Alignment.bottomLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StampButton(
            stamp: 'stamp-approved',
            impressionId: 'decision',
            focusNode: focusNode,
            disabled: disabled,
            child: const Text('Approve'),
          ),
          const StampButton(
            stamp: 'stamp-void',
            text: 'Rejected',
            impressionId: 'decision',
            child: Text('Reject'),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  test('the default label is the stamp in title case', () {
    expect(const StampButton(stamp: 'stamp-approved').spoken, 'Approved');
    expect(const StampButton(text: 'PAST-DUE').spoken, 'Past due');
    expect(const StampButton(stamp: 'stamp-paid').tone, isNotNull);
    expect(
      const StampButton(stamp: 'stamp-draft', ink: StampButtonInk.ink).tone,
      StampButtonInk.ink,
    );
  });

  testWidgets('a strike lands an impression; the same slot replaces it', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_page()));
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(find.byType(StampImpressionMark), findsOneWidget);
    expect(find.bySemanticsLabel('Approved stamped.'), findsOneWidget);
    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();
    final mark = tester.widget<StampImpressionMark>(
      find.byType(StampImpressionMark),
    );
    expect(mark.impression.text, 'Rejected');
    expect(mark.impression.press, 2);
    expect(mark.impression.seed, 'decision#2');
  });

  testWidgets('strikes wander a little around the place', (tester) async {
    StampImpression? struck;
    await tester.pumpWidget(
      componentHost(
        StampButton(
          stamp: 'stamp-paid',
          place: const Offset(0.5, 0.5),
          onStamp: (impression) => struck = impression,
        ),
      ),
    );
    await tester.tap(find.byType(StampButton));
    await tester.pumpAndSettle();
    final impression = struck;
    expect(impression, isNotNull);
    expect((impression?.x ?? 0) - 0.5, inInclusiveRange(-0.03, 0.03));
    expect((impression?.y ?? 0) - 0.5, inInclusiveRange(-0.03, 0.03));
    expect(impression?.turn.abs(), lessThanOrEqualTo(3.5));
  });

  testWidgets('controlled surfaces report and show the parent value', (
    tester,
  ) async {
    var marks = <StampImpression>[];
    await tester.pumpWidget(
      componentHost(
        StatefulBuilder(
          builder: (context, setState) => _page(
            value: marks,
            onValueChanged: (next) => setState(() => marks = next),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(marks, hasLength(1));
    expect(marks.single.name, 'stamp-approved');
    final saved = StampImpression.fromJson(marks.single.toJson());
    expect(saved.key, marks.single.key);
    expect(saved.x, marks.single.x);
  });

  testWidgets('Enter and Space stamp; disabled does not', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final marks = <List<StampImpression>>[];
    await tester.pumpWidget(
      componentHost(_page(focusNode: focusNode, onValueChanged: marks.add)),
    );
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(marks, hasLength(2));
    expect(marks.last.single.press, 2);
    await tester.pumpWidget(
      componentHost(_page(disabled: true, onValueChanged: marks.add)),
    );
    await tester.tap(find.text('Approve'), warnIfMissed: false);
    expect(marks, hasLength(2));
  });

  testWidgets('the tool is a named button with the stamp metrics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const StampButton(stamp: 'stamp-approved')),
    );
    expect(
      tester.getSemantics(find.byType(InkInteraction)),
      matchesSemantics(
        label: 'Approved',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    final size = tester.getSize(find.byType(InkSurface));
    expect(size.height, stampKnob + 38);
    expect(size.width, greaterThanOrEqualTo(112));
    handle.dispose();
  });
}
