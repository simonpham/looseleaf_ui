import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/kevin_sans.dart';
import '../../support/overlay_host.dart';
import '../../support/paper_panel.dart';

Widget _field(String name, String label, String placeholder, {String? help}) =>
    InkFormField<String>(
      name: name,
      validator: (value) => switch (value) {
        final text? when text.contains('@') || name == 'username' =>
          switch (text.length >= 2) {
            true => null,
            false => 'Your name needs at least 2 letters.',
          },
        _ => 'Enter an address like ada@notes.dev.',
      },
      builder: (context, field) => FormItem(
        children: [
          FormLabel(Text(label)),
          FormControl(
            child: Input(
              seed: name,
              placeholder: placeholder,
              invalid: field.invalid,
              onChanged: field.onChanged,
            ),
          ),
          if (help != null) FormDescription(Text(help)),
          FormMessage(seed: name),
        ],
      ),
    );

Widget _form(FormController form) => SizedBox(
  width: 384,
  child: InkForm(
    controller: form,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d20,
      children: [
        _field(
          'username',
          'Name',
          'Ada',
          help: 'Shown on the pages you write.',
        ),
        _field('email', 'Email', 'ada@notes.dev'),
        Button(seed: 'save', onPressed: () {}, child: const Text('Save')),
      ],
    ),
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('form-errors in the light theme', (tester) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final form = FormController(initialValues: {'username': '', 'email': ''});
    addTearDown(form.dispose);
    await tester.pumpWidget(overlayHost(paperPanel(_form(form))));
    await form.handleSubmit((_) {});
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/form-errors.png'),
    );
  });
}
