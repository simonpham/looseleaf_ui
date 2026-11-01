import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _row(List<Widget> children) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: Spacing.d32,
  children: children,
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('sticker-peel in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d32,
            children: [
              _row([
                for (final name in [
                  'done',
                  'sale',
                  'cursor-click',
                  'hand-point-right',
                ])
                  Sticker(name),
              ]),
              _row(const [
                Sticker('done', peel: Peel.auto()),
                Sticker('sale', peel: Peel(22)),
                Sticker('cursor-click', peel: Peel.auto(), rotate: -5),
                Sticker('hand-point-right', peel: Peel(16), rotate: 4),
              ]),
              _row(const [
                Sticker('stamp-approved'),
                Sticker('done', size: 48, shadow: false),
              ]),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/sticker-peel.png'),
    );
  });
}
