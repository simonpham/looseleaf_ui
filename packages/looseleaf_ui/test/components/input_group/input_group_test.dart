import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Set<InkState> _states(WidgetTester tester) => tester
    .widget<InkSurface>(
      find
          .descendant(
            of: find.byType(InputGroup),
            matching: find.byType(InkSurface),
          )
          .first,
    )
    .states;

Widget _host(Widget child) => overlayHost(SizedBox(width: 280, child: child));

void main() {
  testWidgets('focusing the control draws the focus ring', (tester) async {
    await tester.pumpWidget(
      _host(
        const InputGroup(
          children: [
            InputGroupAddon(child: Text('@')),
            InputGroupInput(placeholder: 'handle'),
          ],
        ),
      ),
    );
    expect(_states(tester), isNot(contains(InkState.focused)));
    await tester.tap(find.byType(InputGroupInput));
    await tester.pump();
    expect(_states(tester), contains(InkState.focused));
  });

  testWidgets('tapping an addon focuses the control', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      _host(
        InputGroup(
          focusNode: focusNode,
          children: const [
            InputGroupAddon(child: Text('https://')),
            InputGroupInput(),
          ],
        ),
      ),
    );
    await tester.tap(find.text('https://'));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('addons go where they align, whatever the order', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const InputGroup(
          children: [
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: Text('USD'),
            ),
            InputGroupInput(),
            InputGroupAddon(child: Text(r'$')),
          ],
        ),
      ),
    );
    final dollar = tester.getCenter(find.text(r'$')).dx;
    final control = tester.getCenter(find.byType(InputGroupInput)).dx;
    final usd = tester.getCenter(find.text('USD')).dx;
    expect(dollar < control && control < usd, isTrue);
    expect(tester.getSize(find.byType(InputGroup)).height, Spacing.d36);
  });

  testWidgets('inline addons tighten the input inset', (tester) async {
    await tester.pumpWidget(
      _host(
        const InputGroup(
          children: [
            InputGroupAddon(child: Text('@')),
            InputGroupInput(),
          ],
        ),
      ),
    );
    final control = tester.widget<InputControl>(find.byType(InputControl));
    expect(
      control.padding,
      const EdgeInsetsDirectional.fromSTEB(
        Spacing.d8,
        Spacing.d4,
        Spacing.d12,
        Spacing.d4,
      ),
    );
  });

  testWidgets('a disabled group disables its control and buttons', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      _host(
        InputGroup(
          disabled: true,
          invalid: true,
          children: [
            const InputGroupInput(),
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: InputGroupButton(
                onPressed: () => presses++,
                child: const Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Send'), warnIfMissed: false);
    expect(presses, 0);
    expect(_states(tester), {InkState.disabled, InkState.invalid});
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).readOnly,
      isTrue,
    );
  });

  testWidgets('block addons stack around a growing textarea', (tester) async {
    await tester.pumpWidget(
      _host(
        const InputGroup(
          children: [
            InputGroupAddon(
              align: InputGroupAlign.blockStart,
              border: InputGroupEdge.bottom,
              child: Text('Header'),
            ),
            InputGroupTextarea(),
            InputGroupAddon(
              align: InputGroupAlign.blockEnd,
              child: Text('Footer'),
            ),
          ],
        ),
      ),
    );
    final header = tester.getCenter(find.text('Header')).dy;
    final control = tester.getCenter(find.byType(InputGroupTextarea)).dy;
    final footer = tester.getCenter(find.text('Footer')).dy;
    expect(header < control && control < footer, isTrue);
    final before = tester.getSize(find.byType(InputGroup)).height;
    await tester.enterText(find.byType(EditableText), '1\n2\n3\n4');
    await tester.pump();
    expect(tester.getSize(find.byType(InputGroup)).height, greaterThan(before));
  });

  testWidgets('reads as a named group around a text field', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const InputGroup(
          semanticLabel: 'Search',
          children: [InputGroupInput(semanticLabel: 'Query')],
        ),
      ),
    );
    expect(find.bySemanticsLabel('Search'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(EditableText)),
      isSemantics(label: 'Query', isTextField: true),
    );
    handle.dispose();
  });
}
