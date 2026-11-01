import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

InkSurface _surface(WidgetTester tester) =>
    tester.widget<InkSurface>(find.byType(InkSurface));

void main() {
  testWidgets('a plain ribbon is text, not a button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const Ribbon(child: Text('New'))));
    expect(find.byType(InkInteraction), findsNothing);
    expect(
      tester.getSemantics(find.byType(Ribbon)),
      matchesSemantics(label: 'New'),
    );
    expect(_surface(tester).source.paramsKey, contains('"hoverable":false'));
    handle.dispose();
  });

  testWidgets('with onPressed it is a button on tap, Enter and Space', (
    tester,
  ) async {
    var presses = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(
        Ribbon(
          focusNode: focusNode,
          onPressed: () => presses++,
          child: const Text('Shop'),
        ),
      ),
    );
    await tester.tap(find.byType(Ribbon));
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(presses, 3);
    expect(_surface(tester).source.paramsKey, contains('"hoverable":true'));
  });

  testWidgets('hover lifts a button ribbon by a pixel', (tester) async {
    await tester.pumpWidget(
      componentHost(Ribbon(onPressed: () {}, child: const Text('Shop'))),
    );
    final rest = tester.getTopLeft(find.byType(InkSurface));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(Ribbon)));
    await tester.pumpAndSettle();
    expect(_surface(tester).states, contains(InkState.hovered));
    expect(
      tester.getTopLeft(find.byType(InkSurface)),
      rest + const Offset(0, -1),
    );
    await mouse.removePointer();
  });

  testWidgets('metrics follow the band, tails and gutter', (tester) async {
    for (final (variant, size) in [
      (RibbonVariant.banner, RibbonSize.regular),
      (RibbonVariant.swallow, RibbonSize.sm),
      (RibbonVariant.flag, RibbonSize.lg),
    ]) {
      await tester.pumpWidget(
        componentHost(
          Ribbon(
            variant: variant,
            size: size,
            child: const SizedBox(width: Spacing.d40),
          ),
        ),
      );
      final box = tester.getSize(find.byType(InkSurface));
      final pad = ribbonInset(variant, size) + ribbonGutter(variant);
      expect(box.height, size.band + ribbonDrop(variant, size));
      expect(box.width, 40 + 2 * pad);
    }
  });
}
