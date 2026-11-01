import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _desk(Widget child) => RepaintBoundary(
  child: ColoredBox(
    color: const LooseleafThemeData().colors.desk,
    child: Padding(
      padding: const EdgeInsets.all(Spacing.d40),
      child: child,
    ),
  ),
);

Widget _labelled(String label, Widget sheet) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  spacing: Spacing.d8,
  children: [sheet, Text(label)],
);

Widget _grid(List<Widget> children) => Wrap(
  spacing: Spacing.d32,
  runSpacing: Spacing.d32,
  children: children,
);

const Size _sheet = Size(180, 80);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1760, 2000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(_desk(child)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('paper-stocks in the light theme', (tester) async {
    await _pump(
      tester,
      SizedBox(
        width: 780,
        child: _grid([
          for (final stock in StockName.values)
            _labelled(
              stock.id,
              Paper(
                stock: stock,
                seed: stock.id,
                child: SizedBox.fromSize(size: _sheet),
              ),
            ),
        ]),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/paper-stocks.png'),
    );
  });

  testWidgets('paper-edges in the light theme', (tester) async {
    await _pump(
      tester,
      SizedBox(
        width: 780,
        child: _grid([
          for (final edge in EdgeKind.values)
            _labelled(
              edge.name,
              Paper(
                edge: EdgeSpec.all(edge),
                seed: edge.name,
                child: SizedBox.fromSize(size: _sheet),
              ),
            ),
          _labelled(
            'torn below',
            Paper(
              edge: const EdgeSpec(bottom: EdgeKind.torn),
              seed: 'one-side',
              child: SizedBox.fromSize(size: _sheet),
            ),
          ),
        ]),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/paper-edges.png'),
    );
  });

  testWidgets('paper-props in the light theme', (tester) async {
    const pad = EdgeInsets.all(Spacing.d20);
    await _pump(
      tester,
      SizedBox(
        width: 780,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d56,
          children: [
            const SizedBox(height: Spacing.d24),
            _grid([
              const Paper(
                tape: PaperTape.both,
                tapeKind: TapeKind.washiDots,
                seed: 'a',
                padding: pad,
                child: SizedBox(width: 180, child: Text('Taped up')),
              ),
              const Paper(
                stock: StockName.indexCard,
                fastener: FastenerKind.pin,
                seed: 'b',
                padding: pad,
                child: SizedBox(width: 180, child: Text('Pinned')),
              ),
              const Paper(
                stock: StockName.slip,
                fastener: FastenerKind.clip,
                fastenerTone: Accent.sky,
                seed: 'c',
                padding: pad,
                child: SizedBox(width: 180, child: Text('Clipped')),
              ),
            ]),
            _grid([
              for (final (stock, curl) in const [
                (StockName.stickyYellow, true),
                (StockName.stickyGreen, false),
                (StockName.stickyPink, true),
                (StockName.stickyBlue, false),
              ])
                Paper(
                  stock: stock,
                  curl: curl,
                  seed: stock.id,
                  padding: pad,
                  child: SizedBox.square(
                    dimension: 104,
                    child: Text(stock.id.replaceFirst('sticky-', '')),
                  ),
                ),
            ]),
            const Paper(
              rules: RuleName.ruled,
              seed: 'notes',
              padding: EdgeInsets.fromLTRB(56, 16, 16, 24),
              child: SizedBox(
                width: 360,
                height: 196,
                child: Text('Tuesday. Rain on the window, three cups of tea.'),
              ),
            ),
            const Paper(
              tape: PaperTape.top,
              rules: RuleName.ruledHand,
              seed: 'hand',
              child: SizedBox(width: 360, height: 120),
            ),
          ],
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/paper-props.png'),
    );
  });
}
