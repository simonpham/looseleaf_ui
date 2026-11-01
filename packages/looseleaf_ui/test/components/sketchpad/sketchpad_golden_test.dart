import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';
import 'sketch_fixtures.dart';

void main() {
  setUpAll(() async {
    await InkTextures.instance.load();
    await loadKevinSans();
  });

  testWidgets('the default pad with a drawing', (tester) async {
    tester.view.physicalSize = const Size(560, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          SizedBox(
            width: 480,
            child: Sketchpad(
              seed: 'golden',
              width: 480,
              height: 300,
              controller: SketchpadController(strokes: sketchFixture),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/sketchpad-default.png'),
    );
  });

  testWidgets('papers, read-only and disabled', (tester) async {
    tester.view.physicalSize = const Size(760, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget pad(
      SketchpadPaper paper, {
      bool readOnly = false,
      bool disabled = false,
    }) => SizedBox(
      width: 220,
      child: Sketchpad(
        seed: paper.name,
        width: 480,
        height: 300,
        readOnly: readOnly,
        disabled: disabled,
        controller: SketchpadController(strokes: sketchFixture),
        child: SketchpadCanvas(paper: paper),
      ),
    );
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          Wrap(
            spacing: Spacing.d24,
            runSpacing: Spacing.d24,
            children: [
              for (final paper in SketchpadPaper.values) pad(paper),
              pad(SketchpadPaper.plain, readOnly: true),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/sketchpad-papers.png'),
    );
  });

  testWidgets('picker states and the focused canvas', (tester) async {
    tester.view.physicalSize = const Size(560, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const states = <Set<InkState>>[
      {},
      {InkState.hovered},
      {InkState.focused},
    ];
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          SizedBox(
            width: 480,
            child: Sketchpad(
              seed: 'states',
              width: 480,
              height: 120,
              controller: SketchpadController(tool: SketchTool.pencil),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d16,
                children: [
                  Row(
                    children: [
                      for (final (i, forced) in states.indexed)
                        SketchpadTool(
                          value: SketchTool.values[i],
                          seed: 'tool-$i',
                          forcedStates: forced,
                        ),
                      const SketchpadTool(value: SketchTool.pencil, seed: 'on'),
                      for (final (i, forced) in states.indexed)
                        SketchpadColor(
                          value: SketchColor.values[i + 2],
                          seed: 'color-$i',
                          forcedStates: forced,
                        ),
                    ],
                  ),
                  const SketchpadCanvas(
                    seed: 'canvas',
                    forcedStates: {InkState.focused},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/sketchpad-states.png'),
    );
  });
}
