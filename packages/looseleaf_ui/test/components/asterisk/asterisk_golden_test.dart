import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('asterisk-marks in the light theme', (tester) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                for (final mark in AsteriskMark.values)
                  Asterisk(
                    mark: mark,
                    seed: 'm-${mark.id}',
                    child: Text('a footnote, ${mark.id}'),
                  ),
                for (final tone in AsteriskTone.values)
                  Asterisk(
                    tone: tone,
                    seed: 't-${tone.name}',
                    child: Text('${tone.name} pen'),
                  ),
                DefaultTextStyle.merge(
                  style: const LooseleafTypography().face(
                    KevinSansFace.script,
                    cssSize: 48,
                  ),
                  child: Asterisk(
                    label: 'Footnote 1',
                    onPressed: () {},
                    seed: 'price',
                    child: const Text(r'$16'),
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
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/asterisk-marks.png'),
    );
  });
}
