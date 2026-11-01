import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

double _turn(WidgetTester tester) => tester
    .widget<Transform>(
      find
          .descendant(
            of: find.byType(LabelTag),
            matching: find.byType(Transform),
          )
          .first,
    )
    .transform
    .getRotation()
    .entry(1, 0);

void main() {
  testWidgets('a price tag is 128 wide, at least 160 tall, below its string', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const LabelTag(
          seed: 't',
          children: [LabelTagTitle(Text('Sale')), LabelTagPrice(Text('12'))],
        ),
      ),
    );
    final tag = tester.getRect(find.byType(LabelTag));
    expect(tag.size, const Size(128, 160 + 36));
    expect(
      tester.getTopLeft(find.text('Sale')) - tag.topLeft,
      const Offset(12, 36 + 44),
    );
    expect(tester.getBottomLeft(find.text('12')).dy, tag.bottom - 16);
  });

  testWidgets('a round tag sits lower under its arch', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const LabelTag(
          shape: TagShape.round,
          string: 20,
          children: [LabelTagTitle(Text('New'))],
        ),
      ),
    );
    final tag = tester.getRect(find.byType(LabelTag));
    expect(tester.getTopLeft(find.text('New')).dy - tag.top, 20 + 48);
  });

  testWidgets('a luggage tag is 96 tall and hangs from the start', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const LabelTag(
          shape: TagShape.luggage,
          string: 60,
          children: [LabelTagTitle(Text('Ada'))],
        ),
      ),
    );
    final tag = tester.getRect(find.byType(LabelTag));
    expect(tag.size, const Size(60 + 176, 96));
    expect(tester.getTopLeft(find.text('Ada')).dx - tag.left, 60 + 44);
  });

  testWidgets('turns on its eyelet within the tilt budget, flat when calm', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const LabelTag(tiltDegrees: -3)));
    await tester.pumpAndSettle();
    expect(_turn(tester), closeTo(-0.0349, 1e-3));
    await tester.pumpWidget(
      componentHost(
        const LabelTag(tiltDegrees: -3),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    await tester.pumpAndSettle();
    expect(_turn(tester), 0);
  });

  testWidgets('a pressable tag swings on hover and presses with keys', (
    tester,
  ) async {
    var presses = 0;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      componentHost(
        LabelTag(
          tilt: false,
          onPressed: () => presses++,
          focusNode: focus,
          children: const [LabelTagTitle(Text('Sale'))],
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Sale')));
    await tester.pumpAndSettle();
    expect(_turn(tester), closeTo(-0.0454, 1e-3));
    await tester.tap(find.text('Sale'));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(presses, 3);
  });

  testWidgets('a plain tag does not swing', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const LabelTag(
          tilt: false,
          forcedStates: {InkState.hovered},
          children: [LabelTagTitle(Text('Sale'))],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(_turn(tester), 0);
  });

  testWidgets('a pressable tag is a named button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        LabelTag(
          onPressed: () {},
          semanticLabel: 'Sale section',
          children: const [LabelTagTitle(Text('Sale'))],
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Sale')),
      matchesSemantics(
        label: 'Sale section\nSale',
        isButton: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('the price is red darkened with ink, in the type face', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const LabelTag(children: [LabelTagPrice(Text('4.50'))]),
      ),
    );
    final colors = const LooseleafThemeData().colors;
    final style = tester
        .widget<RichText>(
          find.descendant(
            of: find.byType(LabelTagPrice),
            matching: find.byType(RichText),
          ),
        )
        .text
        .style;
    expect(style?.color, Color.lerp(colors.ink, colors.red, 0.6));
  });
}
