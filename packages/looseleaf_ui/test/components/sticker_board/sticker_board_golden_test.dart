import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

const start = [
  StickerBoardItem(
    id: 'planet',
    name: 'ringed-planet',
    x: 130,
    y: 130,
    rot: -8,
    scale: 1.2,
    z: 0,
  ),
  StickerBoardItem(
    id: 'rocket',
    name: 'rocket',
    x: 290,
    y: 100,
    rot: 24,
    scale: 1,
    z: 1,
  ),
  StickerBoardItem(
    id: 'cloud',
    name: 'cloud-smile',
    x: 432,
    y: 150,
    rot: -3,
    scale: 1.1,
    z: 2,
  ),
  StickerBoardItem(
    id: 'sun',
    name: 'sun-shades',
    x: 310,
    y: 262,
    rot: 10,
    scale: 1.25,
    z: 3,
  ),
  StickerBoardItem(
    id: 'done',
    name: 'done',
    x: 130,
    y: 290,
    rot: 6,
    scale: 0.9,
    z: 4,
  ),
];

Future<void> _shoot(WidgetTester tester, Widget board, String name) async {
  tester.view.physicalSize = const Size(1280, 1100);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    componentHost(paperPanel(SizedBox(width: 560, child: board))),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('../goldens/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('sticker-board-default in the light theme', (tester) async {
    await _shoot(
      tester,
      const StickerBoard(
        defaultValue: start,
        children: [StickerBoardCanvas(height: 380), StickerBoardToolbar()],
      ),
      'sticker-board-default',
    );
  });

  testWidgets('sticker-board-selected in the light theme', (tester) async {
    await _shoot(
      tester,
      const StickerBoard(
        defaultValue: start,
        defaultSelectedId: 'sun',
        children: [StickerBoardCanvas(height: 380), StickerBoardToolbar()],
      ),
      'sticker-board-selected',
    );
  });

  testWidgets('sticker-board-empty in the light theme', (tester) async {
    await _shoot(
      tester,
      const StickerBoard(readOnly: true),
      'sticker-board-empty',
    );
  });
}
