import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

InkSurface _surface(WidgetTester tester) =>
    tester.widget<InkSurface>(find.byType(InkSurface));

Color? _labelColor(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

void main() {
  const colors = LooseleafColors();

  testWidgets('counts stop at max+', (tester) async {
    await tester.pumpWidget(componentHost(const Badge(count: 42)));
    expect(find.text('42'), findsOneWidget);
    await tester.pumpWidget(componentHost(const Badge(count: 128)));
    expect(find.text('99+'), findsOneWidget);
    await tester.pumpWidget(componentHost(const Badge(count: 1200, max: 999)));
    expect(find.text('999+'), findsOneWidget);
  });

  testWidgets('tally draws marks and reads the digits', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const Badge(tally: true, count: 7, seed: 't')),
    );
    expect(find.text('7'), findsNothing);
    expect(_surface(tester).source.paramsKey, contains('"tally":7'));
    expect(
      tester.getSize(find.byType(InkSurface)).width,
      badgeTallyWidth(7, 24) + 2 * 6,
    );
    expect(
      tester.getSemantics(find.byType(Badge)),
      matchesSemantics(label: '7'),
    );
    await tester.pumpWidget(componentHost(const Badge(tally: true, count: 21)));
    expect(find.text('21'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('sizes follow the upstream heights and padding', (tester) async {
    for (final (size, density, height, padding) in [
      (BadgeSize.sm, LooseleafDensity.comfortable, 20.0, 8.0),
      (BadgeSize.regular, LooseleafDensity.comfortable, 24.0, 10.0),
      (BadgeSize.regular, LooseleafDensity.calm, 20.0, 10.0),
      (BadgeSize.lg, LooseleafDensity.compact, 28.0, 12.0),
    ]) {
      await tester.pumpWidget(
        componentHost(
          Badge(
            size: size,
            child: const SizedBox(width: Spacing.d40),
          ),
          theme: LooseleafThemeData(density: density),
        ),
      );
      expect(
        tester.getSize(find.byType(InkSurface)),
        Size(40 + 2 * padding, height),
        reason: '${size.id} at ${density.name}',
      );
    }
  });

  testWidgets('a leading icon tightens the start padding', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Badge(
          leading: SizedBox.square(dimension: Spacing.d14),
          child: SizedBox(width: Spacing.d40),
        ),
      ),
    );
    expect(tester.getSize(find.byType(InkSurface)).width, 8 + 14 + 4 + 40 + 10);
  });

  testWidgets('labels take the variant color', (tester) async {
    for (final (variant, color) in [
      (BadgeVariant.primary, colors.ink),
      (BadgeVariant.destructive, colors.paper),
      (BadgeVariant.link, colors.link),
    ]) {
      await tester.pumpWidget(
        componentHost(Badge(variant: variant, child: Text(variant.id))),
      );
      expect(_labelColor(tester, variant.id), color);
    }
  });

  testWidgets('a plain badge is not focusable and draws no hover', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const Badge(child: Text('New'))));
    expect(find.byType(InkInteraction), findsNothing);
    expect(_surface(tester).source.paramsKey, isNot(contains('hoverable')));
  });

  testWidgets('onPressed makes a link badge: tap, keys, hover', (
    tester,
  ) async {
    var presses = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        Badge(
          variant: BadgeVariant.link,
          focusNode: focusNode,
          onPressed: () => presses++,
          child: const Text('Docs'),
        ),
      ),
    );
    expect(_surface(tester).source.paramsKey, contains('"hoverable":true'));
    await tester.tap(find.byType(Badge));
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(presses, 2);
    expect(
      tester.getSemantics(find.byType(Badge)),
      matchesSemantics(
        label: 'Docs',
        isButton: true,
        isFocusable: true,
        isFocused: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(Badge)));
    await tester.pumpAndSettle();
    expect(_labelColor(tester, 'Docs'), colors.linkHover);
    await mouse.removePointer();
    handle.dispose();
  });
}
