import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';
import '../../support/semantics_matchers.dart';

Set<InkState> _states(WidgetTester tester) =>
    tester.widget<InkSurface>(find.byType(InkSurface)).states;

Widget _host(Widget child) => overlayHost(SizedBox(width: 240, child: child));

void main() {
  testWidgets('tapping the box focuses it and draws the focus ring', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const Input(placeholder: 'Email')));
    expect(_states(tester), isNot(contains(InkState.focused)));
    await tester.tap(find.byType(Input));
    await tester.pump();
    expect(_states(tester), contains(InkState.focused));
  });

  testWidgets('typing calls onChanged and hides the placeholder', (
    tester,
  ) async {
    final values = <String>[];
    await tester.pumpWidget(
      _host(Input(placeholder: 'Email', onChanged: values.add)),
    );
    await tester.enterText(find.byType(EditableText), 'ada@example.com');
    await tester.pump();
    expect(values.last, 'ada@example.com');
    final placeholder = find.byWidgetPredicate(
      (widget) => widget is Visibility && !widget.visible,
    );
    expect(placeholder, findsOneWidget);
  });

  testWidgets('submitting calls onSubmitted', (tester) async {
    String? submitted;
    await tester.pumpWidget(
      _host(Input(onSubmitted: (value) => submitted = value)),
    );
    await tester.enterText(find.byType(EditableText), 'done');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submitted, 'done');
  });

  testWidgets('hover shows the hover layer', (tester) async {
    await tester.pumpWidget(_host(const Input()));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(Input)));
    await tester.pump();
    expect(_states(tester), contains(InkState.hovered));
  });

  testWidgets('disabled cannot be focused or edited', (tester) async {
    await tester.pumpWidget(_host(const Input(disabled: true, invalid: true)));
    await tester.tap(find.byType(Input), warnIfMissed: false);
    await tester.pump();
    expect(_states(tester), {InkState.disabled, InkState.invalid});
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).readOnly,
      isTrue,
    );
  });

  testWidgets('invalid keeps room for the mark at the end', (tester) async {
    await tester.pumpWidget(_host(const Input(invalid: true)));
    final control = tester.widget<InputControl>(find.byType(InputControl));
    expect(
      control.padding,
      const EdgeInsetsDirectional.fromSTEB(
        Spacing.d12,
        Spacing.d4,
        InputMetrics.invalidEnd,
        Spacing.d4,
      ),
    );
  });

  testWidgets('height replaces the density height', (tester) async {
    await tester.pumpWidget(_host(const Input(height: Spacing.d32)));
    expect(tester.getSize(find.byType(Input)).height, Spacing.d32);
  });

  testWidgets('a prefix sits at start-3 and the text starts at ps-9', (
    tester,
  ) async {
    const icon = SizedBox.square(key: ValueKey('icon'), dimension: Spacing.d16);
    await tester.pumpWidget(_host(const Input(prefix: icon)));
    final box = tester.getTopLeft(find.byType(Input));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('icon'))).dx - box.dx,
      12,
    );
    expect(
      tester.getTopLeft(find.byType(EditableText)).dx - box.dx,
      Spacing.d36,
    );
  });

  testWidgets('a suffix sits at end-3 after the text', (tester) async {
    const hint = SizedBox(
      key: ValueKey('hint'),
      width: Spacing.d24,
      height: Spacing.d16,
    );
    await tester.pumpWidget(_host(const Input(suffix: hint)));
    final box = tester.getTopRight(find.byType(Input));
    expect(
      box.dx - tester.getTopRight(find.byKey(const ValueKey('hint'))).dx,
      12,
    );
    expect(
      tester.getTopRight(find.byType(EditableText)).dx,
      tester.getTopLeft(find.byKey(const ValueKey('hint'))).dx - Spacing.d8,
    );
  });

  testWidgets('height follows the density', (tester) async {
    for (final (density, height) in [
      (LooseleafDensity.comfortable, Spacing.d36),
      (LooseleafDensity.compact, Spacing.d32),
      (LooseleafDensity.calm, Spacing.d28),
    ]) {
      await tester.pumpWidget(
        overlayHost(
          const SizedBox(width: 200, child: Input()),
          theme: LooseleafThemeData(density: density),
        ),
      );
      expect(tester.getSize(find.byType(Input)).height, height);
    }
  });

  testWidgets('reads as a named text field with its placeholder as hint', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const Input(semanticLabel: 'Email', placeholder: 'you@example.com'),
      ),
    );
    expect(
      tester.getSemantics(find.byType(EditableText)),
      includesSemantics(
        label: 'Email',
        hint: 'you@example.com',
        isTextField: true,
        isEnabled: true,
      ),
    );
    handle.dispose();
  });
}
