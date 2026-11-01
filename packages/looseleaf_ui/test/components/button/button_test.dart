import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Set<InkState> _surfaceStates(WidgetTester tester) =>
    tester.widget<InkSurface>(find.byType(InkSurface)).states;

Color? _labelColor(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

void main() {
  const colors = LooseleafColors();

  testWidgets('calls onPressed on tap, Enter and Space', (tester) async {
    var presses = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(
        Button(
          focusNode: focusNode,
          onPressed: () => presses++,
          child: const Text('Save'),
        ),
      ),
    );
    await tester.tap(find.byType(Button));
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(presses, 3);
  });

  testWidgets('disabled ignores input and draws the disabled layer', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      componentHost(
        Button(
          disabled: true,
          onPressed: () => presses++,
          child: const Text('Save'),
        ),
      ),
    );
    await tester.tap(find.byType(Button), warnIfMissed: false);
    expect(presses, 0);
    expect(_surfaceStates(tester), {InkState.disabled});
    expect(_labelColor(tester, 'Save'), colors.pencilText);
    final source = tester.widget<InkSurface>(find.byType(InkSurface)).source;
    expect(source.paramsKey, contains('"disabled":true'));
  });

  testWidgets('is a button to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(Button(onPressed: () {}, child: const Text('Save'))),
    );
    expect(
      tester.getSemantics(find.byType(Button)),
      matchesSemantics(
        label: 'Save',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('labels take the variant color', (tester) async {
    for (final (variant, color) in [
      (ButtonVariant.primary, colors.ink),
      (ButtonVariant.destructive, colors.paper),
      (ButtonVariant.outline, colors.ink),
      (ButtonVariant.link, colors.link),
    ]) {
      await tester.pumpWidget(
        componentHost(Button(variant: variant, child: Text(variant.id))),
      );
      expect(_labelColor(tester, variant.id), color);
    }
  });

  testWidgets('a hovered link turns link-hover and wipes in', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Button(variant: ButtonVariant.link, child: Text('Read more')),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(Button)));
    await tester.pumpAndSettle();
    expect(_labelColor(tester, 'Read more'), colors.linkHover);
    expect(
      tester.widget<InkSurface>(find.byType(InkSurface)).swipeOnHover,
      isTrue,
    );
    await mouse.removePointer();
  });

  testWidgets('sizes follow the upstream heights per density', (tester) async {
    for (final (size, density, height) in [
      (ButtonSize.regular, LooseleafDensity.comfortable, 36.0),
      (ButtonSize.regular, LooseleafDensity.compact, 32.0),
      (ButtonSize.regular, LooseleafDensity.calm, 28.0),
      (ButtonSize.xs, LooseleafDensity.compact, 24.0),
      (ButtonSize.lg, LooseleafDensity.calm, 32.0),
      (ButtonSize.iconSm, LooseleafDensity.comfortable, 32.0),
    ]) {
      await tester.pumpWidget(
        componentHost(
          Button(size: size, child: const Text('Go')),
          theme: LooseleafThemeData(density: density),
        ),
      );
      final box = tester.getSize(find.byType(InkSurface));
      expect(box.height, height, reason: '${size.id} at ${density.name}');
      if (size.isIcon) expect(box.width, height);
    }
  });

  testWidgets('an icon tightens the inline padding', (tester) async {
    const icon = SizedBox.square(dimension: Spacing.d16);
    await tester.pumpWidget(
      componentHost(const Button(child: SizedBox(width: Spacing.d40))),
    );
    expect(tester.getSize(find.byType(InkSurface)).width, 40 + 2 * 16);
    await tester.pumpWidget(
      componentHost(
        const Button(
          leading: icon,
          child: SizedBox(width: Spacing.d40),
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(InkSurface)).width,
      12 + 16 + 8 + 40 + 12,
    );
  });

  testWidgets('pressing sinks the button by a pixel', (tester) async {
    await tester.pumpWidget(
      componentHost(Button(onPressed: () {}, child: const Text('Save'))),
    );
    final rest = tester.getTopLeft(find.byType(InkSurface));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Button)),
    );
    await tester.pumpAndSettle();
    expect(_surfaceStates(tester), contains(InkState.pressed));
    expect(
      tester.getTopLeft(find.byType(InkSurface)),
      rest + const Offset(0, 1),
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(InkSurface)), rest);
  });
}
