import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/overlay_host.dart';

Color? _color(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

double _gap(WidgetTester tester, String above, String below) =>
    tester.getTopLeft(find.text(below)).dy -
    tester.getBottomLeft(find.text(above)).dy;

void main() {
  const colors = LooseleafColors();

  testWidgets('a vertical field stacks its parts 12 px apart', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: Field(
            children: [
              FieldLabel(child: Text('Name')),
              SizedBox(key: Key('control'), height: 36),
              FieldDescription(Text('Help')),
              FieldError(errors: ['Wrong']),
            ],
          ),
        ),
      ),
    );
    final label = tester.getRect(
      find.ancestor(of: find.text('Name'), matching: find.byType(FieldLabel)),
    );
    final control = tester.getRect(find.byKey(const Key('control')));
    expect(control.top - label.bottom, 12);
    expect(control.width, 300);
    final description = tester.getRect(find.byType(FieldDescription));
    final error = tester.getRect(find.byType(FieldError));
    expect(error.top - description.bottom, 8);
  });

  testWidgets('invalid turns the label red, disabled graphite', (
    tester,
  ) async {
    for (final (invalid, disabled, color) in [
      (false, false, colors.ink),
      (true, false, colors.red),
      (false, true, colors.pencilText),
    ]) {
      await tester.pumpWidget(
        componentHost(
          SizedBox(
            width: 300,
            child: Field(
              invalid: invalid,
              disabled: disabled,
              children: const [
                FieldLabel(child: Text('Email')),
                FieldDescription(Text('Help')),
              ],
            ),
          ),
        ),
      );
      expect(_color(tester, 'Email'), color);
      expect(_color(tester, 'Help'), colors.inkMuted);
    }
  });

  testWidgets('a horizontal field puts the content beside the control', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 400,
          child: Field(
            orientation: FieldOrientation.horizontal,
            children: [
              Checkbox(value: true, onChanged: (_) {}, seed: 'c'),
              const FieldContent(
                children: [
                  FieldLabel(child: Text('Accept')),
                  FieldDescription(Text('The small print.')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final box = tester.getRect(find.byType(Checkbox));
    final content = tester.getRect(find.byType(FieldContent));
    expect(content.left - box.right, 12);
    expect(content.right, tester.getRect(find.byType(Field)).right);
    expect(box.top - content.top, 1);
    expect(_gap(tester, 'Accept', 'The small print.'), closeTo(6, 0.01));
  });

  testWidgets('responsive fields follow their group width', (tester) async {
    Widget group(double width) => SizedBox(
      width: width,
      child: const FieldGroup(
        children: [
          Field(
            orientation: FieldOrientation.responsive,
            children: [
              FieldContent(children: [FieldTitle(Text('Display name'))]),
              SizedBox(width: 100, height: 36),
            ],
          ),
        ],
      ),
    );
    await tester.pumpWidget(componentHost(group(320)));
    expect(find.byType(Row).evaluate().where(_inField), isEmpty);
    await tester.pumpWidget(componentHost(group(500)));
    expect(find.byType(Row).evaluate().where(_inField), isNotEmpty);
  });

  testWidgets('a group spaces fields 28 px and pulls separators closer', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: FieldGroup(
            children: [
              Text('one'),
              Text('two'),
              FieldSeparator(child: Text('or')),
              Text('three'),
            ],
          ),
        ),
      ),
    );
    expect(_gap(tester, 'one', 'two'), 28);
    final separator = tester.getRect(find.byType(FieldSeparator));
    expect(separator.height, 20);
    expect(separator.top - tester.getBottomLeft(find.text('two')).dy, 20);
  });

  testWidgets('a set puts a description close under its legend', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: FieldSet(
            children: [
              FieldLegend(Text('Notebook')),
              FieldDescription(Text('Saved as you write.')),
              Text('field'),
            ],
          ),
        ),
      ),
    );
    expect(_gap(tester, 'Notebook', 'Saved as you write.'), 6);
    expect(_gap(tester, 'Saved as you write.', 'field'), 24);
  });

  testWidgets('gap replaces the group and set spacing', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: FieldGroup(
            gap: Spacing.d16,
            children: [
              Text('one'),
              FieldSet(
                gap: Spacing.d12,
                children: [
                  FieldLegend(Text('Notebook')),
                  Text('two'),
                  Text('three'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(_gap(tester, 'one', 'Notebook'), 16);
    expect(_gap(tester, 'two', 'three'), 12);
  });

  testWidgets('a label focuses its control and calls onPressed', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    var presses = 0;
    await tester.pumpWidget(
      overlayHost(
        SizedBox(
          width: 300,
          child: Field(
            children: [
              FieldLabel(
                focusNode: focus,
                onPressed: () => presses++,
                child: const Text('Name'),
              ),
              Input(focusNode: focus, seed: 'i'),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Name'));
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    expect(presses, 1);
  });

  testWidgets('a label around a field is a choice card', (tester) async {
    var value = 'a';
    await tester.pumpWidget(
      componentHost(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 360,
            child: FieldLabel(
              seed: 'card',
              checked: value == 'b',
              onPressed: () => setState(() => value = 'b'),
              child: const Field(
                orientation: FieldOrientation.horizontal,
                children: [
                  FieldContent(children: [FieldTitle(Text('Studio'))]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    InkSurface surface() => tester.widget<InkSurface>(find.byType(InkSurface));
    expect(surface().states, isEmpty);
    expect(
      tester.getTopLeft(find.text('Studio')) -
          tester.getTopLeft(find.byType(InkSurface)),
      const Offset(16, 16),
    );
    await tester.tap(find.byType(FieldLabel));
    await tester.pump();
    expect(surface().states, {InkState.checked});
  });

  testWidgets('errors: one line, a list, duplicates collapse, none hides', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const FieldError(errors: ['Too short', 'Too short'])),
    );
    expect(find.text('Too short'), findsOneWidget);
    expect(find.text('•'), findsNothing);
    expect(_color(tester, 'Too short'), colors.red);
    expect(
      tester.getSemantics(find.byType(FieldError)),
      matchesSemantics(label: 'Too short', isLiveRegion: true),
    );
    await tester.pumpWidget(
      componentHost(const FieldError(errors: ['A', null, 'B'])),
    );
    expect(find.text('•'), findsNWidgets(2));
    await tester.pumpWidget(componentHost(const FieldError(errors: [])));
    expect(find.byType(InkSurface), findsNothing);
    handle.dispose();
  });

  test('splitFieldClass sends state variants and padding to the control', () {
    expect(
      splitFieldClass(
        'w-full max-w-56 px-3 focus-visible:ring-2 placeholder:text-red '
        'aria-invalid:border md:py-2 resize-none field-sizing-content '
        'aria-[x]:border hover:bg-red',
      ),
      (
        frame: 'w-full max-w-56 aria-[x]:border hover:bg-red',
        control:
            'px-3 focus-visible:ring-2 placeholder:text-red '
            'aria-invalid:border md:py-2 resize-none '
            'field-sizing-content',
      ),
    );
    expect(splitFieldClass(null), (frame: '', control: ''));
    expect(splitFieldClass('!p-2 [&:hover]:p-1'), (
      frame: '',
      control: '!p-2 [&:hover]:p-1',
    ));
  });

  testWidgets('a horizontal field of buttons wraps when narrow', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 200,
          child: Field(
            orientation: FieldOrientation.horizontal,
            children: [
              Button(onPressed: () {}, child: const Text('Create account')),
              Button(onPressed: () {}, child: const Text('Hide errors')),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('Hide errors')).dy,
      greaterThan(tester.getTopLeft(find.text('Create account')).dy),
    );
  });
}

bool _inField(Element element) {
  var found = false;
  element.visitAncestorElements((ancestor) {
    if (ancestor.widget is Field) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}
