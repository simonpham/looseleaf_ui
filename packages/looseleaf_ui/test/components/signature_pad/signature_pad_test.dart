import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Future<void> _sign(WidgetTester tester) async {
  final origin = tester.getCenter(find.byType(SketchpadCanvas));
  final gesture = await tester.startGesture(
    origin - const Offset(120, 0),
    kind: PointerDeviceKind.mouse,
  );
  for (var i = 1; i <= 12; i++) {
    await gesture.moveBy(Offset(16, (i.isEven ? 10 : -10)));
  }
  await gesture.up();
  await tester.pump();
  await tester.pump();
}

Widget _host(Widget pad) => overlayHost(SizedBox(width: 480, child: pad));

void main() {
  testWidgets('drawing publishes an SVG data URL with its detail', (
    tester,
  ) async {
    final values = <(String, SignatureDetail)>[];
    await tester.pumpWidget(
      _host(
        SignaturePad(onChanged: (value, detail) => values.add((value, detail))),
      ),
    );
    expect(find.text('Sign here'), findsOneWidget);
    await _sign(tester);
    final (value, detail) = values.last;
    expect(value, startsWith('data:image/svg+xml'));
    expect(Uri.decodeComponent(value), contains('<title>Signature</title>'));
    expect(detail.mode, SignatureMode.draw);
    expect(detail.strokes.single.tool, DrawTool.brush);
    expect(detail.strokes.single.color, SketchColor.inkYou);
    expect(find.text('Sign here'), findsNothing);
    await tester.tap(find.text('Clear'));
    await tester.pump();
    await tester.pump();
    expect(values.last.$1, isEmpty);
    expect(find.text('Sign here'), findsOneWidget);
  });

  testWidgets('typing instead letters the name', (tester) async {
    final values = <(String, SignatureDetail)>[];
    final modes = <SignatureMode>[];
    await tester.pumpWidget(
      _host(
        SignaturePad(
          onChanged: (value, detail) => values.add((value, detail)),
          onModeChanged: modes.add,
        ),
      ),
    );
    expect(find.byType(Input), findsNothing);
    await tester.tap(find.text('Type instead'));
    await tester.pump();
    expect(modes, [SignatureMode.type]);
    expect(find.text('Type your name below'), findsOneWidget);
    expect(find.text('Draw instead'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'Ada');
    await tester.pump();
    await tester.pump();
    expect(values.last.$2.text, 'Ada');
    expect(values.last.$2.mode, SignatureMode.type);
    expect(Uri.decodeComponent(values.last.$1), contains('<svg'));
    await tester.tap(find.text('Clear'));
    await tester.pump();
    await tester.pump();
    expect(values.last.$1, isEmpty);
  });

  testWidgets('a required pad fails validation, then passes once signed', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      _host(Form(key: form, child: const SignaturePad(required: true))),
    );
    expect(form.currentState?.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please sign in the box.'), findsOneWidget);
    await _sign(tester);
    expect(find.text('Please sign in the box.'), findsNothing);
    expect(form.currentState?.validate(), isTrue);
    form.currentState?.reset();
    await tester.pump();
    await tester.pump();
    expect(find.text('Sign here'), findsOneWidget);
    expect(form.currentState?.validate(), isFalse);
  });

  testWidgets('a value from outside shows as an image', (tester) async {
    final svg = SignatureExport.svg(
      SignatureMode.type,
      const [],
      'Grace',
      width: 480,
      height: 180,
      seed: 'g',
    );
    await tester.pumpWidget(
      _host(SignaturePad(value: svgDataUrl(svg), readOnly: true)),
    );
    expect(find.byType(SignatureImage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SignatureImage),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
    expect(find.text('Clear'), findsNothing);
    expect(find.text('Sign here'), findsNothing);
    final drawn = SignatureExport.svg(
      SignatureMode.draw,
      const [
        SketchStroke(
          id: 'a',
          tool: DrawTool.brush,
          color: SketchColor.inkYou,
          size: 1,
          pts: [(10, 10, null), (60, 40, null), (120, 20, null)],
        ),
      ],
      '',
      width: 480,
      height: 180,
      seed: 'd',
    );
    await tester.pumpWidget(
      _host(SignaturePad(value: svgDataUrl(drawn), readOnly: true)),
    );
    expect(
      find.descendant(
        of: find.byType(SignatureImage),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('disabled and read-only lock the pad', (tester) async {
    final values = <String>[];
    await tester.pumpWidget(
      _host(SignaturePad(disabled: true, onChanged: (v, _) => values.add(v))),
    );
    await _sign(tester);
    expect(values, isEmpty);
    expect(
      tester
          .widget<Button>(find.widgetWithText(Button, 'Type instead'))
          .disabled,
      isTrue,
    );
  });

  testWidgets('the png format publishes a PNG data URL', (tester) async {
    final values = <String>[];
    await tester.pumpWidget(
      _host(
        SignaturePad(
          format: SignatureFormat.png,
          onChanged: (v, _) => values.add(v),
        ),
      ),
    );
    await _sign(tester);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    expect(values.last, startsWith('data:image/png;base64,'));
  });
}
