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

  testWidgets('stamp-shapes in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d32,
            children: [
              _row(const [
                Stamp(name: 'stamp-approved'),
                Stamp(name: 'stamp-draft'),
                Stamp(name: 'stamp-paid'),
                Stamp(name: 'stamp-urgent'),
              ]),
              _row(const [
                Stamp(
                  text: 'Received',
                  sub: 'Mar 14 2026',
                  ink: StampPadInk.inkYou,
                  h: 72,
                ),
                Stamp(
                  text: 'Members',
                  shape: StampShape.round,
                  ring: 'MEMBERS - EST 2026 -',
                  ink: StampPadInk.inkYou,
                  size: 96,
                ),
                Stamp(
                  text: 'New',
                  shape: StampShape.burst,
                  sub: 'issue',
                  ink: StampPadInk.ink,
                  size: 96,
                ),
                Stamp(text: 'Void', shape: StampShape.voided, w: 160, h: 64),
              ]),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/stamp-shapes.png'),
    );
  });
}
