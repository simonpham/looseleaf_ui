import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

const _people = ['Ada', 'Lin', 'Stubby', 'Grace'];

class _People extends StatelessWidget {
  const _People();

  @override
  Widget build(BuildContext context) {
    final model = PromptInputModel.of(context);
    final query = (model.trigger?.query ?? '').toLowerCase();
    final people = [
      for (final person in _people)
        if (person.toLowerCase().startsWith(query)) person,
    ];
    return PromptInputSuggestions(
      trigger: '@',
      open: switch (model.trigger?.char) {
        '@' => people.isNotEmpty,
        _ => false,
      },
      children: [
        for (final person in people)
          PromptInputSuggestion(
            onSelect: () => model.replaceTrigger('@$person'),
            children: [Text(person)],
          ),
      ],
    );
  }
}

Widget _composer({
  ValueChanged<String>? onSubmit,
  PromptInputStatus status = PromptInputStatus.ready,
  VoidCallback? onStop,
  bool disabled = false,
  TextEditingController? controller,
  PromptInputSubmitOn submitOn = PromptInputSubmitOn.enter,
}) => overlayHost(
  SizedBox(
    width: 480,
    child: PromptInput(
      seed: 'p',
      controller: controller,
      onSubmit: onSubmit,
      status: status,
      onStop: onStop,
      disabled: disabled,
      submitOn: submitOn,
      triggers: const [
        PromptInputTrigger('/', atStart: true),
        PromptInputTrigger('@'),
      ],
      children: const [
        _People(),
        PromptInputBody(child: PromptInputTextarea()),
        PromptInputFooter(
          children: [
            PromptInputHint(Text('Enter to send')),
            PromptInputSubmit(),
          ],
        ),
      ],
    ),
  ),
);

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(EditableText), text);
  await tester.pump();
}

void main() {
  test('detects trigger words before the caret', () {
    const triggers = [
      PromptInputTrigger('/', atStart: true),
      PromptInputTrigger('@'),
    ];
    expect(
      PromptInputActiveTrigger.detect('Thanks @Ad', 10, triggers),
      const PromptInputActiveTrigger(char: '@', query: 'Ad', from: 7, to: 10),
    );
    expect(PromptInputActiveTrigger.detect('hi /cmd', 7, triggers), isNull);
    expect(
      PromptInputActiveTrigger.detect('/sum', 4, triggers)?.query,
      'sum',
    );
    expect(PromptInputActiveTrigger.detect('@a b', 4, triggers), isNull);
    expect(PromptInputActiveTrigger.detect('', 0, triggers), isNull);
  });

  testWidgets('Enter sends and clears; Shift+Enter does not', (tester) async {
    final sent = <String>[];
    await tester.pumpWidget(_composer(onSubmit: sent.add));
    await tester.tap(find.byType(EditableText));
    await _type(tester, 'hello');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    expect(sent, isEmpty);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(sent, ['hello']);
    expect(find.text('hello'), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('blank text is not sent; the submit is disabled', (
    tester,
  ) async {
    final sent = <String>[];
    await tester.pumpWidget(_composer(onSubmit: sent.add));
    await tester.tap(find.byType(EditableText));
    await _type(tester, '   ');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(sent, isEmpty);
    final submit = tester.widget<Button>(
      find.descendant(
        of: find.byType(PromptInputSubmit),
        matching: find.byType(Button),
      ),
    );
    expect(submit.disabled, isTrue);
    expect(submit.semanticLabel, 'Send message');
  });

  testWidgets('mod-enter mode sends only with Ctrl', (tester) async {
    final sent = <String>[];
    await tester.pumpWidget(
      _composer(onSubmit: sent.add, submitOn: PromptInputSubmitOn.modEnter),
    );
    await tester.tap(find.byType(EditableText));
    await _type(tester, 'hi');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(sent, isEmpty);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    expect(sent, ['hi']);
    await tester.pumpAndSettle();
  });

  testWidgets('busy turns the submit into a stop button', (tester) async {
    var stops = 0;
    final sent = <String>[];
    final controller = TextEditingController(text: 'more');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _composer(
        controller: controller,
        onSubmit: sent.add,
        status: PromptInputStatus.streaming,
        onStop: () => stops++,
      ),
    );
    final submit = find.descendant(
      of: find.byType(PromptInputSubmit),
      matching: find.byType(Button),
    );
    expect(tester.widget<Button>(submit).semanticLabel, 'Stop generating');
    expect(tester.widget<Button>(submit).variant, ButtonVariant.outline);
    await tester.tap(submit);
    expect(stops, 1);
    await tester.tap(find.byType(EditableText));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(sent, isEmpty);
  });

  testWidgets('suggestions open on a trigger; arrows and Enter pick', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_composer(controller: controller));
    await tester.tap(find.byType(EditableText));
    await _type(tester, 'Thanks @');
    expect(find.text('Stubby'), findsOneWidget);
    await _type(tester, 'Thanks @s');
    expect(find.text('Ada'), findsNothing);
    expect(find.text('Stubby'), findsOneWidget);
    await _type(tester, 'Thanks @');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(controller.text, 'Thanks @Lin ');
    expect(controller.selection.baseOffset, 12);
    expect(find.text('Ada'), findsNothing);
  });

  testWidgets('Escape dismisses the list; a tap picks', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_composer(controller: controller));
    await tester.tap(find.byType(EditableText));
    await _type(tester, '@');
    expect(find.text('Grace'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('Grace'), findsNothing);
    await _type(tester, 'hi @g');
    await tester.tap(find.text('Grace'));
    await tester.pump();
    expect(controller.text, 'hi @Grace ');
  });

  testWidgets('disabled draws the dashed line and blocks sending', (
    tester,
  ) async {
    await tester.pumpWidget(_composer(disabled: true));
    final body = tester.widget<InkSurface>(
      find.descendant(
        of: find.byType(PromptInputBody),
        matching: find.byType(InkSurface),
      ),
    );
    expect(body.states, contains(InkState.disabled));
  });

  testWidgets('focus draws the brush line', (tester) async {
    await tester.pumpWidget(_composer());
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    final body = tester.widget<InkSurface>(
      find.descendant(
        of: find.byType(PromptInputBody),
        matching: find.byType(InkSurface),
      ),
    );
    expect(body.states, {InkState.focused});
  });
}
