import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

Widget _label(String text) => Center(
  child: Builder(
    builder: (context) => Text(
      text,
      style: LooseleafTheme.of(context).typography.title(cssSize: 24),
    ),
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('resizable-panels in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d24,
            children: [
              SizedBox(
                width: 448,
                height: 256,
                child: ResizablePanelGroup(
                  children: [
                    ResizablePanel(
                      defaultSize: 50,
                      minSize: 20,
                      child: _label('One'),
                    ),
                    const ResizableHandle(withHandle: true, seed: 'h1'),
                    ResizablePanel(
                      defaultSize: 50,
                      minSize: 20,
                      child: ResizablePanelGroup(
                        axis: Axis.vertical,
                        children: [
                          ResizablePanel(defaultSize: 25, child: _label('Two')),
                          const ResizableHandle(withHandle: true, seed: 'h2'),
                          ResizablePanel(
                            defaultSize: 75,
                            child: _label('Three'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 448,
                height: 120,
                child: ResizablePanelGroup(
                  children: [
                    ResizablePanel(child: _label('Rest')),
                    const ResizableHandle(seed: 'a'),
                    ResizablePanel(child: _label('Hover')),
                    const ResizableHandle(
                      seed: 'b',
                      forcedStates: {InkState.hovered},
                    ),
                    ResizablePanel(child: _label('Drag')),
                    const ResizableHandle(
                      seed: 'c',
                      forcedStates: {InkState.pressed},
                    ),
                    ResizablePanel(child: _label('Focus')),
                    const ResizableHandle(
                      seed: 'd',
                      withHandle: true,
                      forcedStates: {InkState.focused},
                    ),
                    ResizablePanel(child: _label('End')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/resizable-panels.png'),
    );
  });
}
