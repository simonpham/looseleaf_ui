import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Set<InkState> _states(WidgetTester tester, int index) => tester
    .widget<InkSurface>(
      find.descendant(
        of: find.byType(RatingItem).at(index - 1),
        matching: find.byType(InkSurface),
      ),
    )
    .states;

Finder _radio(String label) => find.bySemanticsLabel(label);

/// [child] after an autofocused stop, so Tab has somewhere to start.
Widget _afterStop(Widget child) => Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Focus(autofocus: true, child: SizedBox.square(dimension: 8)),
    child,
  ],
);

void main() {
  testWidgets('a tap chooses; clearable taps clear', (tester) async {
    final values = <double>[];
    await tester.pumpWidget(
      componentHost(Rating(clearable: true, onChanged: values.add)),
    );
    await tester.tap(find.byType(RatingItem).at(2));
    await tester.pump();
    expect(values, [3]);
    expect(_states(tester, 3), contains(InkState.checked));
    expect(_states(tester, 4), isNot(contains(InkState.checked)));
    await tester.tap(find.byType(RatingItem).at(2));
    await tester.pump();
    expect(values, [3, 0]);
  });

  testWidgets('halves fill half a glyph', (tester) async {
    await tester.pumpWidget(
      componentHost(const Rating(initialValue: 3.5, allowHalf: true)),
    );
    expect(_states(tester, 3), contains(InkState.checked));
    expect(_states(tester, 4), contains(InkState.indeterminate));
    expect(_states(tester, 5), isEmpty);
  });

  testWidgets('the mouse previews and leaving restores', (tester) async {
    await tester.pumpWidget(componentHost(const Rating(initialValue: 1)));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(
      location: tester.getCenter(find.byType(RatingItem).at(3)),
    );
    await tester.pump();
    expect(_states(tester, 4), contains(InkState.checked));
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(_states(tester, 4), isEmpty);
    expect(_states(tester, 1), contains(InkState.checked));
    await mouse.removePointer();
  });

  testWidgets('arrows, Home and End move and choose', (tester) async {
    final handle = tester.ensureSemantics();
    var value = 2.0;
    await tester.pumpWidget(
      componentHost(
        _afterStop(
          StatefulBuilder(
            builder: (context, setState) => Rating(
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final focused = FocusManager.instance.primaryFocus?.debugLabel;
    expect(focused, 'Rating 2');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, 3);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'Rating 3');
    expect(_states(tester, 3), contains(InkState.focused));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(value, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(value, 5);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(value, 1);
    handle.dispose();
  });

  testWidgets('left and right swap in right-to-left', (tester) async {
    var value = 2.0;
    await tester.pumpWidget(
      componentHost(
        _afterStop(
          Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder: (context, setState) => Rating(
                value: value,
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(value, 3);
  });

  testWidgets('radios are named and checked', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const Rating(
          initialValue: 3.5,
          allowHalf: true,
          semanticLabel: 'Rate this notebook',
        ),
      ),
    );
    expect(
      tester.getSemantics(_radio('3.5 of 5')),
      matchesSemantics(
        label: '3.5 of 5',
        isInMutuallyExclusiveGroup: true,
        hasCheckedState: true,
        isChecked: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(_radio('4 of 5'), findsOneWidget);
    expect(find.bySemanticsLabel('Rate this notebook'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('read-only is an image with the value', (tester) async {
    final handle = tester.ensureSemantics();
    final values = <double>[];
    await tester.pumpWidget(
      componentHost(
        Rating(
          initialValue: 4.5,
          allowHalf: true,
          readOnly: true,
          onChanged: values.add,
        ),
      ),
    );
    expect(find.bySemanticsLabel('Rated 4.5 out of 5'), findsOneWidget);
    expect(_radio('1 of 5'), findsNothing);
    await tester.tap(find.byType(RatingItem).first, warnIfMissed: false);
    expect(values, isEmpty);
    handle.dispose();
  });

  testWidgets('disabled ignores taps and leaves the tab order', (
    tester,
  ) async {
    final values = <double>[];
    await tester.pumpWidget(
      componentHost(
        _afterStop(
          Rating(initialValue: 2, disabled: true, onChanged: values.add),
        ),
      ),
    );
    await tester.tap(find.byType(RatingItem).at(4), warnIfMissed: false);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(values, isEmpty);
    expect(FocusManager.instance.primaryFocus?.debugLabel, isNot('Rating 2'));
  });

  testWidgets('glyph sizes follow the size', (tester) async {
    for (final size in RatingSize.values) {
      await tester.pumpWidget(componentHost(Rating(size: size)));
      expect(
        tester.getSize(find.byType(InkSurface).first),
        Size.square(size.glyph),
      );
    }
  });
}
