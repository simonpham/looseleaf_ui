import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const Key _shot = Key('shot');

const List<(String, String)> _tools = [
  ('plus', 'Add to library'),
  ('pencil', 'Edit notebook'),
  ('copy', 'Duplicate'),
  ('trash', 'Move to bin'),
  ('settings', 'Settings'),
];

Widget _tool(String icon, String label, {OverlaySide side = OverlaySide.top}) =>
    Tooltip(
      defaultOpen: true,
      content: TooltipContent(side: side, seed: label, child: Text(label)),
      child: Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.icon,
        onPressed: () {},
        seed: icon,
        child: InkIcon(icon),
      ),
    );

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('tooltip-sides in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          key: _shot,
          child: Paper(
            stock: StockName.dotGrid,
            tilt: false,
            shadow: PaperShadow.none,
            seed: 'stage',
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => Stack(
                    children: [
                      Align(
                        alignment: const Alignment(0, -0.45),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: Spacing.d8,
                          children: [
                            for (final (icon, _) in _tools)
                              Button(
                                variant: ButtonVariant.outline,
                                size: ButtonSize.icon,
                                onPressed: () {},
                                seed: icon,
                                child: InkIcon(icon),
                              ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.5, -0.45),
                        child: _tool('plus', 'Add to library'),
                      ),
                      Align(
                        alignment: const Alignment(-0.6, 0.85),
                        child: _tool(
                          'pencil',
                          'On the right',
                          side: OverlaySide.right,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.05, -0.1),
                        child: _tool(
                          'copy',
                          'Below, a longer note that wraps onto two lines',
                          side: OverlaySide.bottom,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.65, 0.85),
                        child: _tool(
                          'trash',
                          'On the left',
                          side: OverlaySide.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/tooltip-sides.png'),
    );
  });
}
