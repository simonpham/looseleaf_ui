import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import 'sketch_fixtures.dart';

Widget _pad(
  SketchpadController controller, {
  bool readOnly = false,
  bool disabled = false,
  ValueChanged<List<SketchStroke>>? onChanged,
}) => componentHost(
  SizedBox(
    width: 480,
    child: Sketchpad(
      seed: 'test',
      width: 480,
      height: 300,
      controller: controller,
      readOnly: readOnly,
      disabled: disabled,
      onChanged: onChanged,
    ),
  ),
);

Finder get _canvas => find.byType(SketchpadCanvas);

int _pointer = 40;

Future<void> _draw(
  WidgetTester tester, {
  PointerDeviceKind kind = PointerDeviceKind.mouse,
  double pressure = 1,
  Offset from = const Offset(-100, -40),
}) async {
  final origin = tester.getCenter(_canvas) + from;
  final pointer = _pointer++;
  final buttons = switch (kind) {
    PointerDeviceKind.mouse => kPrimaryMouseButton,
    _ => kPrimaryButton,
  };
  await tester.sendEventToBinding(
    PointerDownEvent(
      pointer: pointer,
      kind: kind,
      buttons: buttons,
      position: origin,
      pressure: pressure,
      pressureMin: 0,
      pressureMax: 1,
    ),
  );
  for (var i = 1; i <= 10; i++) {
    await tester.sendEventToBinding(
      PointerMoveEvent(
        pointer: pointer,
        kind: kind,
        buttons: buttons,
        position: origin + Offset(i * 15.0, i * 4.0),
        pressure: pressure,
        pressureMin: 0,
        pressureMax: 1,
      ),
    );
  }
  await tester.sendEventToBinding(
    PointerUpEvent(
      pointer: pointer,
      kind: kind,
      position: origin + const Offset(150, 40),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('a mouse drag adds one stroke in the current pen', (
    tester,
  ) async {
    final controller = SketchpadController(color: SketchColor.red);
    addTearDown(controller.dispose);
    final changes = <int>[];
    await tester.pumpWidget(
      _pad(controller, onChanged: (strokes) => changes.add(strokes.length)),
    );
    await _draw(tester);
    expect(controller.strokes, hasLength(1));
    final stroke = controller.strokes.single;
    expect(stroke.tool, DrawTool.felt);
    expect(stroke.color, SketchColor.red);
    expect(stroke.pts.length, greaterThan(5));
    expect(changes, [1]);
    expect(controller.announcement, 'Stroke added. 1 stroke.');
  });

  testWidgets('a pen records pressure and a following touch is a palm', (
    tester,
  ) async {
    final controller = SketchpadController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_pad(controller));
    await _draw(tester, kind: PointerDeviceKind.stylus, pressure: 0.4);
    expect(controller.strokes, hasLength(1));
    expect(controller.strokes.single.pts.first.$3, 0.4);
    await _draw(tester, kind: PointerDeviceKind.touch);
    expect(controller.strokes, hasLength(1));
  });

  testWidgets('the eraser removes the strokes it touches', (tester) async {
    final controller = SketchpadController(
      strokes: sketchFixture,
      tool: SketchTool.eraser,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(_pad(controller));
    final box = tester.getRect(_canvas);
    final gesture = await tester.startGesture(
      box.topLeft + Offset(box.width * 30 / 480, box.height * 223 / 300),
    );
    await gesture.moveBy(const Offset(40, 0));
    await gesture.up();
    await tester.pump();
    expect(controller.strokes.map((s) => s.id), isNot(contains('grass')));
    expect(controller.strokes, hasLength(sketchFixture.length - 1));
  });

  testWidgets('undo, redo and clear from the toolbar and the keys', (
    tester,
  ) async {
    final controller = SketchpadController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_pad(controller));
    await _draw(tester);
    await _draw(tester, from: const Offset(-80, 20));
    expect(controller.strokes, hasLength(2));
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(controller.strokes, hasLength(1));
    await tester.tap(find.text('Redo'));
    await tester.pump();
    expect(controller.strokes, hasLength(2));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    expect(controller.strokes, hasLength(1));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyY);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    expect(controller.strokes, hasLength(2));
    await tester.tap(find.text('Clear'));
    await tester.pump();
    expect(controller.strokes, isEmpty);
    expect(controller.canUndo, isTrue);
  });

  testWidgets('the keyboard draws with the arrows and Space', (tester) async {
    final controller = SketchpadController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_pad(controller));
    await tester.tap(_canvas);
    await tester.pump();
    expect(controller.strokes.single.pts, hasLength(1));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    expect(controller.tool, SketchTool.marker);
    await tester.sendKeyEvent(LogicalKeyboardKey.bracketRight);
    expect(controller.size, SketchSizeName.bold.size);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(controller.announcement, 'Pen down.');
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    final stroke = controller.strokes.last;
    expect(stroke.tool, DrawTool.marker);
    expect(stroke.pts.first, (240.0, 150.0, null));
    expect(stroke.pts.last, (272.0, 158.0, null));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(controller.strokes, hasLength(2));
    expect(controller.announcement, 'Stroke canceled.');
  });

  testWidgets('picking the highlighter swaps a dark ink for yellow', (
    tester,
  ) async {
    final controller = SketchpadController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_pad(controller));
    await tester.tap(find.text('Highlighter'));
    await tester.pump();
    expect(controller.color, SketchColor.hi);
    await tester.tap(find.text('Felt'));
    await tester.pump();
    expect(controller.color, SketchColor.ink);
    await tester.tap(find.bySemanticsLabel('Teal'));
    await tester.tap(find.bySemanticsLabel('Bold line'));
    await tester.pump();
    expect(controller.color, SketchColor.teal);
    expect(controller.size, SketchSizeName.bold.size);
  });

  testWidgets('read-only shows the drawing as an image without a toolbar', (
    tester,
  ) async {
    final controller = SketchpadController(strokes: sketchFixture);
    addTearDown(controller.dispose);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_pad(controller, readOnly: true));
    expect(find.byType(SketchpadToolbar), findsNothing);
    expect(find.bySemanticsLabel('Drawing, 7 strokes'), findsOneWidget);
    await _draw(tester);
    expect(controller.strokes, hasLength(sketchFixture.length));
    handle.dispose();
  });

  testWidgets('disabled stops drawing and the pickers', (tester) async {
    final controller = SketchpadController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_pad(controller, disabled: true));
    await _draw(tester);
    await tester.tap(find.text('Marker'));
    expect(controller.strokes, isEmpty);
    expect(controller.tool, SketchTool.felt);
  });

  testWidgets('replay draws the strokes on in order', (tester) async {
    final controller = SketchpadController(strokes: sketchFixture);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_pad(controller));
    controller.replay();
    await tester.pump();
    final painter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((paint) => paint.painter)
        .whereType<SketchStrokesPainter>()
        .single;
    expect(painter.timings.keys, sketchFixture.map((s) => s.id));
    expect(painter.clock?.value, 0);
    await tester.pumpAndSettle();
    expect(painter.clock?.value, greaterThan(1));
  });

  test('exports an SVG with resolved paints', () {
    final svg = SketchpadExport.svg(
      sketchFixture,
      width: 480,
      height: 300,
      margin: 6,
      title: 'Sketch',
    );
    expect(svg, startsWith('<svg'));
    expect(svg, contains('<title>Sketch</title>'));
    expect(svg, contains('data-stroke="roof"'));
    expect(svg, isNot(contains('var(--ll-paper)')));
    expect(svg, contains('data:image/png;base64,'));
  });

  testWidgets('exports PNG bytes', (tester) async {
    final controller = SketchpadController(strokes: sketchFixture);
    addTearDown(controller.dispose);
    final bytes = await tester.runAsync(
      () => controller.toPng(width: 48, height: 30, scale: 1),
    );
    expect(bytes, isNotNull);
    expect(bytes?.sublist(1, 4), 'PNG'.codeUnits);
  });
}
