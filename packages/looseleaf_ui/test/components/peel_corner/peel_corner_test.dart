import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _corner({
  bool? peeled,
  ValueChanged<bool>? onPeeledChange,
  PeelCornerSide corner = PeelCornerSide.bottomRight,
  VoidCallback? onCopy,
  LooseleafThemeData theme = const LooseleafThemeData(),
}) => componentHost(
  SizedBox(
    width: 320,
    child: PeelCorner(
      peeled: peeled,
      onPeeledChange: onPeeledChange,
      corner: corner,
      label: 'Reveal the code',
      children: [
        const PeelCornerPage(child: SizedBox(height: 168)),
        PeelCornerUnder(
          child: GestureDetector(onTap: onCopy, child: const Text('SAVE10')),
        ),
      ],
    ),
  ),
  theme: theme,
);

double _peel(WidgetTester tester) => PeelCornerScope.of(
  tester.element(find.byType(PeelCornerPage)),
).peel.value;

bool _open(WidgetTester tester) =>
    PeelCornerScope.of(tester.element(find.byType(PeelCornerPage))).open;

Finder get _trigger => find.byType(InkInteraction);

void main() {
  testWidgets('height sets the page, and with it the corner, h-52', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 320,
          child: PeelCorner(
            children: [
              PeelCornerPage(height: 208, child: Text('Spring sale')),
              PeelCornerUnder(child: Text('SAVE10')),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(PeelCornerPage)).height, 208);
    expect(tester.getSize(find.byType(PeelCorner)).height, 208);
  });

  testWidgets('rests slightly curled; a tap opens and closes it', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(_corner(onPeeledChange: changes.add));
    expect(_peel(tester), closeTo(24, 0.01));
    await tester.tap(_trigger);
    await tester.pumpAndSettle();
    expect(_open(tester), isTrue);
    expect(_peel(tester), closeTo(120, 0.01));
    await tester.tap(_trigger);
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
    expect(_peel(tester), closeTo(24, 0.01));
  });

  testWidgets('the trigger is a 56 px button in the corner', (tester) async {
    await tester.pumpWidget(_corner());
    final page = tester.getRect(find.byType(PeelCorner));
    final hit = tester.getRect(_trigger);
    expect(hit.size, const Size.square(56));
    expect(hit.bottomRight, page.bottomRight);
    await tester.pumpWidget(_corner(corner: PeelCornerSide.bottomLeft));
    expect(tester.getRect(_trigger).bottomLeft, page.bottomLeft);
    expect(
      tester.getSemantics(_trigger),
      matchesSemantics(
        label: 'Reveal the code',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });

  testWidgets('Enter and Space toggle it', (tester) async {
    final changes = <bool>[];
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      componentHost(
        PeelCorner(
          focusNode: focus,
          onPeeledChange: changes.add,
          children: const [
            PeelCornerPage(child: SizedBox(width: 200, height: 120)),
            PeelCornerUnder(child: Text('code')),
          ],
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
  });

  testWidgets('a drag past the threshold opens; a short one springs back', (
    tester,
  ) async {
    await tester.pumpWidget(_corner());
    final corner = tester.getBottomRight(find.byType(PeelCorner));
    final drag = await tester.startGesture(corner - const Offset(4, 4));
    await drag.moveBy(const Offset(-30, -30));
    await tester.pump();
    expect(_peel(tester), closeTo(34, 0.01));
    await drag.up();
    await tester.pumpAndSettle();
    expect(_open(tester), isFalse);
    expect(_peel(tester), closeTo(24, 0.01));

    final pull = await tester.startGesture(corner - const Offset(4, 4));
    await pull.moveBy(const Offset(-90, -90));
    await tester.pump();
    await pull.up();
    await tester.pumpAndSettle();
    expect(_open(tester), isTrue);
    expect(_peel(tester), closeTo(120, 0.01));
  });

  testWidgets('hovering a closed corner lifts it', (tester) async {
    await tester.pumpWidget(_corner());
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(_trigger));
    await tester.pumpAndSettle();
    expect(_peel(tester), closeTo(0.42 * 120, 0.01));
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(_peel(tester), closeTo(24, 0.01));
  });

  testWidgets('a declined change eases back', (tester) async {
    await tester.pumpWidget(_corner(peeled: false, onPeeledChange: (_) {}));
    await tester.tap(_trigger);
    await tester.pumpAndSettle();
    expect(_open(tester), isFalse);
    expect(_peel(tester), closeTo(24, 0.01));
  });

  testWidgets('a controlled corner follows peeled', (tester) async {
    await tester.pumpWidget(_corner(peeled: false));
    await tester.pumpWidget(_corner(peeled: true));
    await tester.pumpAndSettle();
    expect(_peel(tester), closeTo(120, 0.01));
  });

  testWidgets('the sheet underneath is inert until open', (tester) async {
    var copies = 0;
    await tester.pumpWidget(_corner(peeled: false, onCopy: () => copies++));
    expect(find.bySemanticsLabel('SAVE10'), findsNothing);
    await tester.pumpWidget(_corner(peeled: true, onCopy: () => copies++));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('SAVE10'), findsOneWidget);
  });

  testWidgets('the page is cut along the fold', (tester) async {
    await tester.pumpWidget(_corner(peeled: true));
    await tester.pumpAndSettle();
    final clip = tester.widget<ClipPath>(
      find.descendant(
        of: find.byType(PeelCornerPage),
        matching: find.byType(ClipPath),
      ),
    );
    final size = tester.getSize(find.byType(PeelCornerPage));
    expect(size.width, 320);
    final path = clip.clipper?.getClip(size);
    expect(path?.contains(Offset(size.width - 2, size.height - 2)), isFalse);
    expect(path?.contains(Offset(size.width - 130, size.height - 2)), isTrue);
  });

  testWidgets('reduced motion jumps', (tester) async {
    await tester.pumpWidget(
      _corner(theme: const LooseleafThemeData(motion: LooseleafMotion.reduced)),
    );
    await tester.tap(_trigger);
    await tester.pump();
    expect(_peel(tester), 120);
  });
}
