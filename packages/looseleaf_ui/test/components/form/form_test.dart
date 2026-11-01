import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

String? _name(String? value) => switch (value) {
  final name? when name.length >= 2 => null,
  _ => 'Your name needs at least 2 letters.',
};

Widget _form(FormController form, {FocusNode? nameFocus}) => overlayHost(
  SizedBox(
    width: 320,
    child: InkForm(
      controller: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkFormField<String>(
            name: 'username',
            validator: _name,
            builder: (context, field) => FormItem(
              children: [
                const FormLabel(Text('Name')),
                FormControl(
                  child: Input(
                    seed: 'name',
                    focusNode: nameFocus,
                    invalid: field.invalid,
                    onChanged: field.onChanged,
                  ),
                ),
                const FormDescription(Text('Shown on your pages.')),
                const FormMessage(),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);

Color? _color(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

void main() {
  const colors = LooseleafColors();

  test('validates on submit, then on change', () async {
    final form = FormController(initialValues: {'name': ''});
    addTearDown(form.dispose);
    form.register(
      'name',
      (value) => switch (value) {
        '' || null => 'Required',
        _ => null,
      },
    );
    form.setValue('name', '');
    expect(form.error('name'), isNull);
    var saved = <String, Object?>{};
    await form.handleSubmit((values) => saved = values);
    expect(form.error('name'), 'Required');
    expect(saved, isEmpty);
    form.setValue('name', 'Ada');
    expect(form.error('name'), isNull);
    await form.handleSubmit((values) => saved = values);
    expect(saved, {'name': 'Ada'});
    form.setError('name', 'Taken');
    expect(form.isValid, isFalse);
    form.reset();
    expect(form.values, {'name': ''});
    expect(form.isSubmitted, isFalse);
    expect(form.errors, isEmpty);
  });

  testWidgets('a failed submit turns the label red, shows the message and '
      'focuses the control', (tester) async {
    final form = FormController();
    final focus = FocusNode();
    addTearDown(form.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(_form(form, nameFocus: focus));
    expect(find.byType(FieldError), findsNothing);
    expect(_color(tester, 'Name'), colors.ink);
    await form.handleSubmit((_) {});
    await tester.pump();
    expect(find.text('Your name needs at least 2 letters.'), findsOneWidget);
    expect(_color(tester, 'Name'), colors.red);
    expect(focus.hasFocus, isTrue);
    await tester.enterText(find.byType(EditableText), 'Ada');
    await tester.pump();
    expect(find.byType(FieldError), findsNothing);
    expect(form.value<String>('username'), 'Ada');
  });

  testWidgets('the label focuses the control', (tester) async {
    final form = FormController();
    final focus = FocusNode();
    addTearDown(form.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(_form(form, nameFocus: focus));
    await tester.tap(find.text('Name'));
    await tester.pump();
    expect(focus.hasFocus, isTrue);
  });

  testWidgets('the control is invalid to screen readers with an error', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final form = FormController();
    addTearDown(form.dispose);
    await tester.pumpWidget(_form(form));
    form.setError('username', 'Taken');
    await tester.pump();
    final node = tester.getSemantics(find.byType(EditableText));
    expect(node.validationResult, SemanticsValidationResult.invalid);
    expect(find.text('Taken'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a message shows its child without an error', (tester) async {
    final form = FormController();
    addTearDown(form.dispose);
    await tester.pumpWidget(
      overlayHost(
        InkForm(
          controller: form,
          child: InkFormField<bool>(
            name: 'terms',
            builder: (context, field) => const FormItem(
              children: [FormMessage(child: Text('Read them first.'))],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Read them first.'), findsOneWidget);
  });

  testWidgets('removed fields stop validating', (tester) async {
    final form = FormController();
    addTearDown(form.dispose);
    await tester.pumpWidget(_form(form));
    expect(form.validate(), isFalse);
    await tester.pumpWidget(const SizedBox());
    expect(form.validate(), isTrue);
  });
}
