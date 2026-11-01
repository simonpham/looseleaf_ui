import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

class _Harness extends StatefulWidget {
  const _Harness({this.type = ToggleGroupType.single});

  final ToggleGroupType type;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  Set<String> value = {'b'};

  @override
  Widget build(BuildContext context) => FocusScope(
    autofocus: true,
    child: ToggleGroup<String>(
      value: value,
      type: widget.type,
      onChanged: (next) => setState(() => value = next),
      children: const [
        ToggleGroupItem(value: 'a', child: Text('Alpha')),
        ToggleGroupItem(value: 'b', child: Text('Bravo')),
        ToggleGroupItem(value: 'c', child: Text('Charlie')),
      ],
    ),
  );
}

Set<InkState> _states(WidgetTester tester, String label) => tester
    .widget<InkSurface>(
      find.descendant(
        of: find.widgetWithText(ToggleGroupItem<String>, label),
        matching: find.byType(InkSurface),
      ),
    )
    .states;

bool _on(WidgetTester tester, String label) =>
    _states(tester, label).contains(InkState.checked);

void main() {
  testWidgets('single keeps one on and can turn it off', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(_on(tester, 'Alpha'), isTrue);
    expect(_on(tester, 'Bravo'), isFalse);
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(_on(tester, 'Alpha'), isFalse);
  });

  testWidgets('multiple adds and removes', (tester) async {
    await tester.pumpWidget(
      componentHost(const _Harness(type: ToggleGroupType.multiple)),
    );
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(_on(tester, 'Alpha'), isTrue);
    expect(_on(tester, 'Bravo'), isTrue);
    await tester.tap(find.text('Bravo'));
    await tester.pump();
    expect(_on(tester, 'Bravo'), isFalse);
  });

  testWidgets('Tab lands on the pressed item, arrows move, Space presses', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_states(tester, 'Bravo'), contains(InkState.focused));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_states(tester, 'Charlie'), contains(InkState.focused));
    expect(_on(tester, 'Charlie'), isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_states(tester, 'Alpha'), contains(InkState.focused));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(_on(tester, 'Alpha'), isTrue);
  });

  testWidgets('the first joined item draws no seam', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    final sources = [
      for (final label in ['Alpha', 'Bravo'])
        tester
            .widget<InkSurface>(
              find.descendant(
                of: find.widgetWithText(ToggleGroupItem<String>, label),
                matching: find.byType(InkSurface),
              ),
            )
            .source,
    ];
    expect(sources.first, isA<WithoutPartInkSource>());
    expect(sources.last, isNot(isA<WithoutPartInkSource>()));
  });

  testWidgets('single items read as radio choices', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const _Harness()));
    expect(
      tester.getSemantics(
        find.widgetWithText(ToggleGroupItem<String>, 'Bravo'),
      ),
      matchesSemantics(
        label: 'Bravo',
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  test('WithoutPartInkSource strips nested part groups', () {
    final source = WithoutPartInkSource(
      InkSource.callback(
        id: 'x',
        draw: (_) => const InkMarkup(
          parts: {
            'rest': '<path d="M0"/><g data-part="seam"><g><path/></g></g><path d="M1"/>',
          },
          pad: 0,
        ),
      ),
      'seam',
    );
    expect(
      source.draw(const InkFrameRequest(box: Size(4, 4), seed: 's')).parts,
      {'rest': '<path d="M0"/><g/><path d="M1"/>'},
    );
  });
}
