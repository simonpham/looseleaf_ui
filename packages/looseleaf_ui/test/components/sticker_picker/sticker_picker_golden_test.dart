import 'package:flutter/services.dart';
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

Widget _picker({
  bool open = false,
  String? value,
  List<String> recent = const [],
  List<StickerPickerInput>? stickers,
}) => Align(
  alignment: const Alignment(-0.4, -0.85),
  child: StickerPicker(
    defaultOpen: open,
    value: value,
    recent: recent,
    stickers: stickers,
    content: const StickerPickerContent(seed: 'picker'),
    child: StickerPickerTrigger.builder(
      builder: (context, popover) => Button(
        variant: ButtonVariant.outline,
        onPressed: popover.toggle,
        seed: 'add',
        leading: const InkIcon('star'),
        child: const Text('Add sticker'),
      ),
    ),
  ),
);

Future<void> _shoot(WidgetTester tester, Widget child, String name) async {
  tester.view.physicalSize = const Size(1040, 1240);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(_stage(child)));
  await tester.pumpAndSettle();
  await expectLater(
    find.byKey(_shot),
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

  testWidgets('sticker-picker-closed in the light theme', (tester) async {
    await _shoot(tester, _picker(), 'sticker-picker-closed');
  });

  testWidgets('sticker-picker-open in the light theme', (tester) async {
    await _shoot(
      tester,
      _picker(open: true, value: 'rocket', recent: const ['rocket', 'done']),
      'sticker-picker-open',
    );
  });

  testWidgets('sticker-picker-search in the light theme', (tester) async {
    await _shoot(tester, _picker(open: true), 'sticker-picker-search-blank');
    await tester.enterText(find.byType(EditableText), 'cat');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/sticker-picker-search.png'),
    );
    await tester.enterText(find.byType(EditableText), 'qqqq');
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/sticker-picker-empty.png'),
    );
  });
}
