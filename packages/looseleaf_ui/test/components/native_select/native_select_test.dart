import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';
import '../../support/semantics_matchers.dart';

const _options = <NativeSelectEntry<String>>[
  NativeSelectOption(value: 'is', label: 'Iceland'),
  NativeSelectOption(value: 'pt', label: 'Portugal'),
  NativeSelectOption(value: 'jp', label: 'Japan', disabled: true),
  NativeSelectOptGroup(
    label: 'Americas',
    options: [
      NativeSelectOption(value: 'ca', label: 'Canada'),
      NativeSelectOption(value: 'cl', label: 'Chile'),
    ],
  ),
];

class _Harness extends StatefulWidget {
  const _Harness({this.initial, this.focusNode});

  final String? initial;
  final FocusNode? focusNode;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late String? value = widget.initial;

  @override
  Widget build(BuildContext context) => NativeSelect<String>(
    value: value,
    options: _options,
    placeholder: 'Choose a country',
    focusNode: widget.focusNode,
    semanticLabel: 'Country',
    onChanged: (next) => setState(() => value = next),
  );
}

String? _value(WidgetTester tester) => tester
    .widget<NativeSelect<String>>(find.byType(NativeSelect<String>))
    .value;

void main() {
  testWidgets('shows the placeholder, then the chosen words', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    expect(
      tester
          .widget<Visibility>(
            find.ancestor(
              of: find.text('Choose a country'),
              matching: find.byType(Visibility),
            ),
          )
          .visible,
      isTrue,
    );
    await tester.tap(find.byType(NativeSelect<String>));
    await tester.pumpAndSettle();
    expect(find.byType(NativeSelectList<String>), findsOneWidget);
    await tester.tap(find.text('Canada').last);
    await tester.pumpAndSettle();
    expect(_value(tester), 'ca');
    expect(find.byType(NativeSelectList<String>), findsNothing);
  });

  testWidgets('disabled options cannot be chosen', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness(initial: 'is')));
    await tester.tap(find.byType(NativeSelect<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Japan').last);
    await tester.pumpAndSettle();
    expect(_value(tester), 'is');
  });

  testWidgets('the open list takes the arrows, Enter and Escape', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      overlayHost(_Harness(initial: 'is', focusNode: focusNode)),
    );
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.byType(NativeSelectList<String>), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_value(tester), 'ca');
    expect(focusNode.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(NativeSelectList<String>), findsNothing);
    expect(_value(tester), 'ca');
  });

  testWidgets('arrows and letters change the closed select', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      overlayHost(_Harness(initial: 'is', focusNode: focusNode)),
    );
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_value(tester), 'pt');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_value(tester), 'ca');
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.pump();
    expect(_value(tester), 'is');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(_value(tester), 'cl');
    expect(find.byType(NativeSelectList<String>), findsNothing);
  });

  testWidgets('tapping outside closes the list', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.tap(find.byType(NativeSelect<String>));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(NativeSelectList<String>), findsNothing);
  });

  testWidgets('disabled does not open', (tester) async {
    await tester.pumpWidget(
      overlayHost(
        NativeSelect<String>(
          value: null,
          options: _options,
          disabled: true,
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byType(NativeSelect<String>), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(NativeSelectList<String>), findsNothing);
  });

  testWidgets('reads as a named button with its value', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(const _Harness(initial: 'pt')));
    expect(
      tester.getSemantics(find.byType(NativeSelect<String>)),
      includesSemantics(
        label: 'Country',
        value: 'Portugal',
        isButton: true,
        isEnabled: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
  });

  test('typeahead cycles a repeated letter', () {
    final typeahead = NativeSelectTypeahead();
    final labels = ['Canada', 'Chile', 'Cuba'];
    final now = DateTime(2026);
    bool all(int _) => true;
    expect(typeahead.find('c', labels, 0, enabled: all, now: now), 1);
    expect(
      typeahead.find(
        'c',
        labels,
        1,
        enabled: all,
        now: now.add(const Duration(milliseconds: 100)),
      ),
      2,
    );
    expect(
      typeahead.find(
        'c',
        labels,
        2,
        enabled: all,
        now: now.add(const Duration(seconds: 2)),
      ),
      0,
    );
  });
}
