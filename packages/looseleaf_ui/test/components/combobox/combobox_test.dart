import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

const _frameworks = [
  ComboboxItemData(value: 'next', label: 'Next.js'),
  ComboboxItemData(value: 'sveltekit', label: 'SvelteKit'),
  ComboboxItemData(value: 'nuxt', label: 'Nuxt.js'),
  ComboboxItemData(value: 'remix', label: 'Remix', disabled: true),
  ComboboxItemData(value: 'astro', label: 'Astro'),
];

class _Picker extends StatefulWidget {
  const _Picker({this.initial});

  final String? initial;

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  late String? value = widget.initial;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 256,
    child: Combobox(
      items: _frameworks,
      value: value,
      onChanged: (next) => setState(() => value = next),
      label: 'Framework',
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ComboboxTrigger(
            semanticLabel: 'Framework',
            child: ComboboxValue(placeholder: 'Select framework...'),
          ),
          ComboboxContent(
            children: [
              ComboboxInput(placeholder: 'Search framework...'),
              ComboboxList.items(
                children: [ComboboxEmpty(child: Text('No framework found.'))],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Field extends StatefulWidget {
  const _Field();

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  String? value = 'next';
  final List<String> created = [];

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 256,
    child: Combobox(
      items: _frameworks,
      value: value,
      onChanged: (next) => setState(() => value = next),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ComboboxInput(semanticLabel: 'Framework', showClear: true),
          ComboboxContent(
            children: [
              ComboboxList(
                children: [
                  ComboboxGroup(
                    heading: 'Frameworks',
                    children: [
                      for (final item in _frameworks)
                        ComboboxItem(value: item.value, label: item.label),
                    ],
                  ),
                  ComboboxCreate(onCreate: created.add),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Tags extends StatefulWidget {
  const _Tags();

  @override
  State<_Tags> createState() => _TagsState();
}

class _TagsState extends State<_Tags> {
  List<String> values = ['Design', 'Garden'];

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 320,
    child: Combobox.multiple(
      items: const [
        ComboboxItemData.of('Design'),
        ComboboxItemData.of('Garden'),
        ComboboxItemData.of('Travel'),
      ],
      values: values,
      onValuesChanged: (next) => setState(() => values = next),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ComboboxChips(child: ComboboxChipsInput(semanticLabel: 'Labels')),
          ComboboxContent(children: [ComboboxList.items()]),
        ],
      ),
    ),
  );
}

String? _picked(WidgetTester tester) =>
    tester.state<_PickerState>(find.byType(_Picker)).value;

void main() {
  testWidgets('tapping the trigger opens the list with the search focused', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(const _Picker()));
    expect(find.text('SvelteKit'), findsNothing);
    await tester.tap(find.byType(ComboboxTrigger));
    await tester.pumpAndSettle();
    expect(find.text('SvelteKit'), findsOneWidget);
    expect(
      Combobox.of(tester.element(find.byType(ComboboxTrigger)))
          .inputFocus
          .hasFocus,
      isTrue,
    );
  });

  testWidgets('typing filters, Enter chooses and focus returns', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(const _Picker()));
    await tester.tap(find.byType(ComboboxTrigger));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'svelte');
    await tester.pumpAndSettle();
    expect(find.text('Next.js'), findsNothing);
    expect(find.text('SvelteKit'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_picked(tester), 'sveltekit');
    expect(find.byType(ComboboxList), findsNothing);
    final controller = Combobox.of(
      tester.element(find.byType(ComboboxTrigger)),
    );
    expect(controller.triggerFocus.hasFocus, isTrue);
  });

  testWidgets('arrows skip disabled rows, Escape closes', (tester) async {
    await tester.pumpWidget(overlayHost(const _Picker(initial: 'nuxt')));
    await tester.tap(find.byType(ComboboxTrigger));
    await tester.pumpAndSettle();
    final controller = Combobox.of(
      tester.element(find.byType(ComboboxTrigger)),
    );
    expect(controller.active, 'nuxt');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(controller.active, 'astro');
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(controller.active, 'next');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(controller.open, isFalse);
    expect(_picked(tester), 'nuxt');
  });

  testWidgets('a match-less search shows the empty state', (tester) async {
    await tester.pumpWidget(overlayHost(const _Picker()));
    await tester.tap(find.byType(ComboboxTrigger));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No framework found.'), findsOneWidget);
  });

  testWidgets('tapping a row chooses it; tapping outside closes', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(const _Picker()));
    await tester.tap(find.byType(ComboboxTrigger));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Astro'));
    await tester.pumpAndSettle();
    expect(_picked(tester), 'astro');
    expect(find.text('Astro'), findsOneWidget);
    await tester.tap(find.byType(ComboboxTrigger));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(ComboboxList), findsNothing);
  });

  testWidgets('the trigger reads as an expandable button, rows as options', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(const _Picker(initial: 'next')));
    expect(
      tester.getSemantics(find.byType(ComboboxTrigger)),
      isSemantics(
        label: 'Framework\nNext.js',
        isButton: true,
        hasExpandedState: true,
        isExpanded: false,
      ),
    );
    await tester.tap(find.byType(ComboboxTrigger));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byType(ComboboxItem).first),
      isSemantics(label: 'Next.js', isButton: true, isSelected: true),
    );
    handle.dispose();
  });

  testWidgets('the field shows the label, filters once typed in', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(const _Field()));
    await tester.pump();
    expect(find.text('Next.js'), findsOneWidget);
    await tester.tap(find.byType(ComboboxInput));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('Frameworks'), findsOneWidget);
    expect(find.text('Astro'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'nu');
    await tester.pumpAndSettle();
    expect(find.text('Astro'), findsNothing);
    expect(find.text('Nuxt.js'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(tester.state<_FieldState>(find.byType(_Field)).value, 'nuxt');
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'Nuxt.js',
    );
  });

  testWidgets('the create row takes new text', (tester) async {
    await tester.pumpWidget(overlayHost(const _Field()));
    await tester.tap(find.byType(ComboboxInput));
    await tester.enterText(find.byType(EditableText), 'Qwik');
    await tester.pumpAndSettle();
    expect(find.text('Create "Qwik"'), findsOneWidget);
    expect(find.text('Frameworks'), findsNothing);
    await tester.tap(find.text('Create "Qwik"'));
    await tester.pumpAndSettle();
    final state = tester.state<_FieldState>(find.byType(_Field));
    expect(state.value, 'Qwik');
    expect(state.created, ['Qwik']);
  });

  testWidgets('the clear x empties the field', (tester) async {
    await tester.pumpWidget(overlayHost(const _Field()));
    await tester.tap(find.bySemanticsLabel('Clear'));
    await tester.pumpAndSettle();
    expect(tester.state<_FieldState>(find.byType(_Field)).value, isNull);
  });

  testWidgets('chips: choose toggles, Backspace and the x take back', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(const _Tags()));
    List<String> values() =>
        tester.state<_TagsState>(find.byType(_Tags)).values;
    expect(find.byType(ComboboxChip), findsNWidgets(2));
    await tester.tap(find.byType(ComboboxChipsInput));
    await tester.enterText(find.byType(EditableText), 'tra');
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(values(), ['Design', 'Garden', 'Travel']);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      isEmpty,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();
    expect(values(), ['Design', 'Garden']);
    await tester.tap(find.bySemanticsLabel('Remove Design'));
    await tester.pumpAndSettle();
    expect(values(), ['Garden']);
  });

  test('toneOf matches upstream', () {
    expect(ComboboxChips.toneOf('Design'), isA<ChipTone>());
    expect(ComboboxChips.toneOf(''), ChipTone.hi);
  });

  test('the default filter ranks prefix, word and loose matches', () {
    expect(comboboxDefaultFilter('SvelteKit', 'svelte', const []), 1);
    expect(comboboxDefaultFilter('Next.js', 'js', const []), 0.9);
    expect(comboboxDefaultFilter('SvelteKit', 'kit', const []), 0.7);
    expect(comboboxDefaultFilter('Nuxt.js', 'nxj', const []), 0.3);
    expect(comboboxDefaultFilter('Remix', 'zz', const []), 0);
    expect(comboboxDefaultFilter('x', 'zz', const ['Z zz']), 0.9);
  });
}
