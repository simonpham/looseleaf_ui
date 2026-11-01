import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

bool _lit(WidgetTester tester, String label) => tester
    .widget<InkMenuRow>(
      find.ancestor(of: find.text(label), matching: find.byType(InkMenuRow)),
    )
    .highlighted;

Widget _menu({
  List<String>? chosen,
  List<bool>? opens,
  FocusNode? region,
  bool disabled = false,
  TextDirection direction = TextDirection.ltr,
}) => Directionality(
  textDirection: direction,
  child: ContextMenu(
    onOpenChange: opens?.add,
    content: ContextMenuContent(
      seed: 'ctx',
      children: [
        ContextMenuItem(
          inset: true,
          onSelect: () => chosen?.add('Back'),
          child: const Text('Back'),
        ),
        const ContextMenuItem(
          inset: true,
          disabled: true,
          child: Text('Forward'),
        ),
        ContextMenuItem(
          inset: true,
          onSelect: () => chosen?.add('Reload'),
          child: const Text('Reload'),
        ),
      ],
    ),
    child: ContextMenuTrigger(
      disabled: disabled,
      child: Focus(
        focusNode: region,
        child: const SizedBox(
          width: 320,
          height: 176,
          child: Center(child: Text('Right-click anywhere')),
        ),
      ),
    ),
  ),
);

Future<void> _rightClick(WidgetTester tester, Offset at) async {
  await tester.tapAt(at, buttons: kSecondaryButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a right click opens the slip at the pointer', (tester) async {
    final opens = <bool>[];
    await tester.pumpWidget(overlayHost(_menu(opens: opens)));
    final region = tester.getTopLeft(find.byType(SizedBox).last);
    final at = region + const Offset(40, 30);
    await _rightClick(tester, at);
    expect(find.text('Back'), findsOneWidget);
    expect(opens, [true]);
    final slip = tester.getTopLeft(find.byType(InkMenuPanel));
    expect(slip.dx, closeTo(at.dx + ContextMenu.sideOffset, 1));
    expect(slip.dy, closeTo(at.dy, 1));
    expect(_lit(tester, 'Back'), isFalse);
  });

  testWidgets('a long press opens it too', (tester) async {
    await tester.pumpWidget(overlayHost(_menu()));
    await tester.longPress(find.text('Right-click anywhere'));
    await tester.pumpAndSettle();
    expect(find.text('Reload'), findsOneWidget);
  });

  testWidgets('keys move, skip disabled rows and choose', (tester) async {
    final chosen = <String>[];
    await tester.pumpWidget(overlayHost(_menu(chosen: chosen)));
    await _rightClick(tester, tester.getCenter(find.text('Right-click anywhere')));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(_lit(tester, 'Reload'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(chosen, ['Reload']);
    expect(find.text('Reload'), findsNothing);
  });

  testWidgets('a right click outside closes it', (tester) async {
    await tester.pumpWidget(overlayHost(_menu()));
    await _rightClick(tester, tester.getCenter(find.text('Right-click anywhere')));
    expect(find.text('Back'), findsOneWidget);
    await _rightClick(tester, const Offset(4, 4));
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('Shift+F10 opens it on a focused region', (tester) async {
    final region = FocusNode();
    addTearDown(region.dispose);
    await tester.pumpWidget(overlayHost(_menu(region: region)));
    region.requestFocus();
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.f10);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(find.text('Back'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Back'), findsNothing);
    expect(region.hasFocus, isTrue);
  });

  testWidgets('a disabled region ignores right clicks', (tester) async {
    await tester.pumpWidget(overlayHost(_menu(disabled: true)));
    await _rightClick(tester, tester.getCenter(find.text('Right-click anywhere')));
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('it opens on the pointer\'s left in right-to-left', (
    tester,
  ) async {
    await tester.pumpWidget(
      overlayHost(_menu(direction: TextDirection.rtl)),
    );
    final at = tester.getCenter(find.text('Right-click anywhere'));
    await _rightClick(tester, at);
    final slip = tester.getRect(find.byType(InkMenuPanel));
    expect(slip.right, closeTo(at.dx - ContextMenu.sideOffset, 1));
  });

  testWidgets('the slip is a menu for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(_menu()));
    await _rightClick(tester, tester.getCenter(find.text('Right-click anywhere')));
    expect(
      tester.getSemantics(find.text('Back')),
      isSemantics(role: SemanticsRole.menuItem, isEnabled: true),
    );
    handle.dispose();
  });
}
