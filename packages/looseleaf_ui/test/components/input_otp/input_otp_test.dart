import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Widget _otp({
  InputOTPPattern? pattern = InputOTPPattern.digits,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onComplete,
  bool disabled = false,
  TextEditingController? controller,
}) => InputOTP(
  maxLength: 4,
  pattern: pattern,
  controller: controller,
  disabled: disabled,
  onChanged: onChanged,
  onComplete: onComplete,
  semanticLabel: 'One-time code',
  children: const [
    InputOTPGroup(
      children: [InputOTPSlot(index: 0), InputOTPSlot(index: 1)],
    ),
    InputOTPSeparator(),
    InputOTPGroup(
      children: [InputOTPSlot(index: 2), InputOTPSlot(index: 3)],
    ),
  ],
);

List<Set<InkState>> _states(WidgetTester tester) => [
  for (final surface in tester.widgetList<InkSurface>(
    find.descendant(
      of: find.byType(InputOTPSlot),
      matching: find.byType(InkSurface),
    ),
  ))
    surface.states,
];

void main() {
  testWidgets('typing fills the slots and completes the code', (
    tester,
  ) async {
    final changes = <String>[];
    String? completed;
    await tester.pumpWidget(
      overlayHost(
        _otp(onChanged: changes.add, onComplete: (code) => completed = code),
      ),
    );
    await tester.tap(find.byType(InputOTP));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), '12');
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(completed, isNull);
    await tester.enterText(find.byType(EditableText), '1234');
    await tester.pump();
    expect(changes.last, '1234');
    expect(completed, '1234');
  });

  testWidgets('the pattern filters and paste drops separators', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(overlayHost(_otp(controller: controller)));
    await tester.tap(find.byType(InputOTP));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), '12-3 4x5');
    await tester.pump();
    expect(controller.text, '1234');
  });

  testWidgets('the active slot follows the caret and rings', (tester) async {
    await tester.pumpWidget(
      overlayHost(_otp(controller: TextEditingController(text: '1'))),
    );
    expect(_states(tester).every((states) => states.isEmpty), isTrue);
    await tester.tap(find.byType(InputOTP));
    await tester.pump();
    expect(_states(tester)[1], {InkState.focused});
    expect(find.byType(InputOTPCaret), findsOneWidget);
  });

  testWidgets('a full code keeps the last slot active, without a caret', (
    tester,
  ) async {
    await tester.pumpWidget(
      overlayHost(_otp(controller: TextEditingController(text: '1234'))),
    );
    await tester.tap(find.byType(InputOTP));
    await tester.pump();
    expect(_states(tester)[3], {InkState.focused});
    expect(find.byType(InputOTPCaret), findsNothing);
  });

  testWidgets('Backspace empties the last slot', (tester) async {
    final controller = TextEditingController(text: '12');
    addTearDown(controller.dispose);
    await tester.pumpWidget(overlayHost(_otp(controller: controller)));
    await tester.tap(find.byType(InputOTP));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(controller.text, '1');
  });

  testWidgets('disabled cannot be focused', (tester) async {
    await tester.pumpWidget(overlayHost(_otp(disabled: true)));
    await tester.tap(find.byType(InputOTP));
    await tester.pump();
    expect(_states(tester).first, {InkState.disabled});
    expect(find.byType(InputOTPCaret), findsNothing);
  });

  testWidgets('reads as one named text field', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(_otp()));
    expect(find.bySemanticsLabel('One-time code'), findsOneWidget);
    handle.dispose();
  });
}
