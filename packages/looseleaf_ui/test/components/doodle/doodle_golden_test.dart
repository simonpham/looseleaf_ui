import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _row(List<Widget> children) => Row(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.end,
  spacing: Spacing.d24,
  children: children,
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('doodle-sizes in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              _row([
                for (final name in ['star', 'sun', 'flower', 'mushroom'])
                  Doodle(name),
              ]),
              for (final name in ['sun', 'mushroom'])
                _row([
                  for (final size in [32.0, 48.0, 64.0, 96.0, 128.0])
                    Doodle(name, size: size),
                ]),
              _row(const [
                Doodle('star', accent: ArtAccent.sky, rotate: -12),
                Doodle('flower', flip: true),
              ]),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/doodle-sizes.png'),
    );
  });
}
