import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Set<InkState> _states(WidgetTester tester) =>
    tester.widget<InkSurface>(find.byType(InkSurface).last).states;

void main() {
  testWidgets('is a 32 by 48 box', (tester) async {
    await tester.pumpWidget(
      componentHost(Bookmark(value: false, onChanged: (_) {}, seed: 'b')),
    );
    expect(tester.getSize(find.byType(Bookmark)), const Size(32, 48));
  });

  testWidgets('tap, Enter and Space toggle it', (tester) async {
    final values = <bool>[];
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      componentHost(
        Bookmark(
          value: false,
          onChanged: values.add,
          focusNode: focus,
          seed: 'b',
        ),
      ),
    );
    await tester.tap(find.byType(Bookmark));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(values, [true, true, true]);
  });

  testWidgets('a tap in the hit slop toggles it', (tester) async {
    final values = <bool>[];
    await tester.pumpWidget(
      componentHost(Bookmark(value: false, onChanged: values.add, seed: 'b')),
    );
    final box = tester.getRect(find.byType(Bookmark));
    await tester.tapAt(box.bottomRight + const Offset(Spacing.d4, Spacing.d4));
    expect(values, [true]);
  });

  testWidgets('pressed shows the checked ribbon and casts a shadow', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(Bookmark(value: true, onChanged: (_) {}, seed: 'b')),
    );
    expect(_states(tester), contains(InkState.checked));
    expect(find.byType(ImageFiltered), findsNWidgets(2));
    await tester.pumpWidget(
      componentHost(Bookmark(value: false, onChanged: (_) {}, seed: 'b')),
    );
    expect(_states(tester), isNot(contains(InkState.checked)));
    expect(find.byType(ImageFiltered), findsNothing);
  });

  testWidgets('disabled ignores input', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      componentHost(
        Bookmark(value: false, disabled: true, onChanged: (_) => taps++),
      ),
    );
    await tester.tap(find.byType(Bookmark));
    expect(taps, 0);
  });

  testWidgets('keyboard focus draws a ring', (tester) async {
    await tester.pumpWidget(
      componentHost(
        Bookmark(
          value: false,
          onChanged: (_) {},
          forcedStates: const {InkState.focused},
        ),
      ),
    );
    expect(find.byType(DecoratedBox), findsOneWidget);
  });

  testWidgets('is a toggle button named by its label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        Bookmark(
          value: true,
          onChanged: (_) {},
          semanticLabel: 'Save this article',
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Save this article')),
      matchesSemantics(
        label: 'Save this article',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('a fixed turn is clamped to the tilt budget, flat when calm', (
    tester,
  ) async {
    double angle() => tester
        .widget<Transform>(
          find
              .descendant(
                of: find.byType(Bookmark),
                matching: find.byType(Transform),
              )
              .first,
        )
        .transform
        .getRotation()
        .entry(1, 0)
        .abs();
    await tester.pumpWidget(
      componentHost(Bookmark(value: false, tiltDegrees: 9, onChanged: (_) {})),
    );
    expect(angle(), closeTo(0.0349, 1e-3));
    await tester.pumpWidget(
      componentHost(
        Bookmark(value: false, tiltDegrees: 9, onChanged: (_) {}),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(angle(), 0);
  });

  testWidgets('the ribbon is 32 by 56, decorative and ignores input', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const BookmarkRibbon(seed: 'r')));
    expect(tester.getSize(find.byType(BookmarkRibbon)), const Size(32, 56));
    expect(tester.getSemantics(find.byType(BookmarkRibbon)).label, isEmpty);
    expect(find.byType(ImageFiltered), findsNWidgets(2));
    handle.dispose();
  });
}
