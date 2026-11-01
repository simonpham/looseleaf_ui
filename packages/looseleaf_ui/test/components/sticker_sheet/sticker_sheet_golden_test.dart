import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

const _names = [
  'rocket',
  'cloud-smile',
  'sun-shades',
  'ringed-planet',
  'done',
  'rainbow',
  'first-place',
  'number-one',
  'a-plus',
  'hundred',
  'moon-sleepy',
  'sale',
];

Future<void> _shoot(WidgetTester tester, Widget child, String name) async {
  tester.view.physicalSize = const Size(2000, 1000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(paperPanel(child)));
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

  testWidgets('sticker-sheet-default in the light theme', (tester) async {
    await _shoot(
      tester,
      StickerSheet(
        title: 'Sticker sheet no. 4',
        seed: 'sheet',
        defaultPeeled: const ['done', 'hundred'],
        children: [
          for (final name in _names)
            StickerSheetItem(
              name: name,
              forcedStates: switch (name) {
                'rainbow' => const {InkState.hovered},
                'sale' => const {InkState.focused},
                _ => const {},
              },
            ),
        ],
      ),
      'sticker-sheet-default',
    );
  });

  testWidgets('sticker-sheet-backings in the light theme', (tester) async {
    await _shoot(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d32,
        children: [
          StickerSheet(
            title: 'Badges',
            seed: 'badges',
            columns: 3,
            size: 64,
            stickers: ['wip', 'new', 'beta', 'pro', 'ok', 'wow'],
            defaultPeeled: ['beta'],
          ),
          StickerSheet(
            title: 'Kraft',
            seed: 'kraft',
            backing: StickerSheetBacking.kraft,
            columns: 3,
            size: 64,
            stickers: ['rocket', 'cloud-smile', 'sun-shades', 'done'],
          ),
          StickerSheet(
            title: 'Plain',
            seed: 'plain',
            backing: StickerSheetBacking.paper,
            columns: 2,
            size: 80,
            disabled: true,
            stickers: ['first-place', 'number-one', 'a-plus', 'hundred'],
          ),
        ],
      ),
      'sticker-sheet-backings',
    );
  });
}
