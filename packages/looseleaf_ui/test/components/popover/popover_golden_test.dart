import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const Key _shot = Key('shot');

Widget _stage(Widget child) => RepaintBoundary(
  key: _shot,
  child: Paper(
    stock: StockName.dotGrid,
    tilt: false,
    shadow: PaperShadow.none,
    seed: 'stage',
    child: Overlay(
      initialEntries: [OverlayEntry(builder: (context) => child)],
    ),
  ),
);

Widget _trigger(String label) => PopoverTrigger.builder(
  builder: (context, popover) => Button(
    variant: ButtonVariant.outline,
    onPressed: popover.toggle,
    seed: label,
    child: Text(label),
  ),
);

Widget _field(String label, String value) => Row(
  spacing: Spacing.d16,
  children: [
    SizedBox(width: 96, child: Text(label)),
    Expanded(child: Input(placeholder: value)),
  ],
);

Future<void> _shotOf(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(_stage(child)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('popover-dimensions in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(640, 420),
      Align(
        alignment: const Alignment(0, -0.75),
        child: Popover(
          defaultOpen: true,
          content: PopoverContent(
            pin: true,
            seed: 'dimensions',
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d16,
              children: [
                const PopoverHeader(
                  children: [
                    PopoverTitle(Text('Dimensions')),
                    PopoverDescription(
                      Text('Set the dimensions for the layer.'),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d8,
                  children: [
                    _field('Width', '100%'),
                    _field('Max. width', '300px'),
                    _field('Height', '25px'),
                  ],
                ),
              ],
            ),
          ),
          child: _trigger('Open popover'),
        ),
      ),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/popover-dimensions.png'),
    );
  });

  testWidgets('popover-arrows in the light theme', (tester) async {
    Widget note(String label, OverlaySide side, PopoverContent content) =>
        Popover(defaultOpen: true, content: content, child: _trigger(label));
    PopoverContent body(
      String title,
      OverlaySide side, {
      StockName stock = StockName.slip,
      PaperTape? tape,
      EdgeSpec? edge,
      Accent? pin,
    }) => PopoverContent(
      side: side,
      arrow: true,
      width: 168,
      stock: stock,
      tape: tape,
      edge: edge,
      pin: pin != null,
      pinTone: pin,
      seed: title,
      child: PopoverHeader(
        children: [
          PopoverTitle(Text(title)),
          PopoverDescription(Text('On the ${side.name}.')),
        ],
      ),
    );
    await _shotOf(
      tester,
      const Size(980, 560),
      Stack(
        children: [
          Align(
            alignment: const Alignment(-0.15, 0.85),
            child: note(
              'Top',
              OverlaySide.top,
              body(
                'Taped',
                OverlaySide.top,
                stock: StockName.kraft,
                tape: PaperTape.top,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.15, -0.95),
            child: note(
              'Bottom',
              OverlaySide.bottom,
              body(
                'Torn',
                OverlaySide.bottom,
                stock: StockName.indexCard,
                edge: const EdgeSpec(bottom: EdgeKind.torn),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-0.55, -0.1),
            child: note(
              'Right',
              OverlaySide.right,
              body('Pinned', OverlaySide.right, pin: Accent.sky),
            ),
          ),
          Align(
            alignment: const Alignment(0.95, -0.1),
            child: note(
              'Left',
              OverlaySide.left,
              body(
                'Sticky',
                OverlaySide.left,
                stock: StockName.stickyPink,
                pin: Accent.grape,
              ),
            ),
          ),
        ],
      ),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/popover-arrows.png'),
    );
  });
}
