import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/kevin_sans.dart';
import '../../support/overlay_host.dart';
import '../../support/paper_panel.dart';

final List<SketchPoint> _scrawl = [
  for (var t = 0.0; t <= 1; t += 0.01)
    (
      70 + 300 * t,
      110 - 28 * math.sin(t * 18) * (1 - t * 0.5) - 10 * t,
      0.3 + 0.6 * math.sin(t * math.pi),
    ),
];

void main() {
  setUpAll(() async {
    await InkTextures.instance.load();
    await loadKevinSans();
  });

  testWidgets('empty, typed, signed and invalid', (tester) async {
    tester.view.physicalSize = const Size(1080, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget cell(Widget child) => SizedBox(width: 480, child: child);
    await tester.pumpWidget(
      overlayHost(
        paperPanel(
          Wrap(
            spacing: Spacing.d40,
            runSpacing: Spacing.d40,
            children: [
              cell(const SignaturePad(seed: 'empty')),
              cell(
                const SignaturePad(
                  seed: 'typed',
                  initialMode: SignatureMode.type,
                ),
              ),
              cell(const _Signed(seed: 'signed')),
              cell(const SignaturePad(seed: 'invalid', invalid: true)),
              cell(
                SignaturePad(
                  seed: 'image',
                  readOnly: true,
                  value: svgDataUrl(
                    SignatureExport.svg(
                      SignatureMode.type,
                      const [],
                      'Grace Hopper',
                      width: 480,
                      height: 180,
                      seed: 'image',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(EditableText), 'Ada Lovelace');
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/signature-pad-states.png'),
    );
  });
}

class _Signed extends StatefulWidget {
  const _Signed({required this.seed});

  final String seed;

  @override
  State<_Signed> createState() => _SignedState();
}

class _SignedState extends State<_Signed> {
  @override
  Widget build(BuildContext context) => SignaturePad(
    seed: widget.seed,
    child: Builder(
      builder: (context) {
        final sketch = SketchpadScope.of(context).controller;
        if (sketch.strokes.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => sketch.commit([
              SketchStroke(
                id: 'sig',
                tool: DrawTool.brush,
                color: SketchColor.inkYou,
                size: 0.95,
                pts: _scrawl,
              ),
            ], 'Stroke added.'),
          );
        }
        return const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d8,
          children: [
            SignaturePadCanvas(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [SignaturePadClear(), SignaturePadModeToggle()],
            ),
          ],
        );
      },
    ),
  );
}
