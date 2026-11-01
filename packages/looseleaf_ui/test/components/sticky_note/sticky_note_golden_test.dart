import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const _pads = [
  (StickyColor.yellow, 'todo', 'buy more ink'),
  (StickyColor.green, 'done', 'book the venue'),
  (StickyColor.orange, 'careful', 'the glue is wet'),
  (StickyColor.pink, 'urgent', 'call mum'),
  (StickyColor.blue, 'tip', 'tape it down first'),
];

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('sticky-note-pads in the light theme', (tester) async {
    tester.view.physicalSize = const Size(2160, 1400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.desk,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d40),
              child: SizedBox(
                width: 1000,
                child: Wrap(
                  spacing: Spacing.d32,
                  runSpacing: Spacing.d40,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    for (final (color, title, body) in _pads)
                      StickyNote(
                        color: color,
                        seed: title,
                        children: [
                          StickyNoteTitle(Text(title)),
                          StickyNoteContent(Text(body)),
                        ],
                      ),
                    const StickyNote(
                      curl: true,
                      fastener: FastenerKind.pin,
                      seed: 'a',
                      children: [
                        StickyNoteTitle(Text('pinned')),
                        StickyNoteContent(Text('a curl, and a tomato pin')),
                      ],
                    ),
                    const StickyNote(
                      color: StickyColor.blue,
                      tape: PaperTape.top,
                      width: 224,
                      seed: 'b',
                      children: [
                        StickyNoteTitle(Text('taped')),
                        StickyNoteContent(
                          Text('a strip of masking tape across the top'),
                        ),
                        StickyNoteFooter(Text('from Ada')),
                      ],
                    ),
                    const StickyNote(
                      color: StickyColor.green,
                      width: 128,
                      height: 112,
                      seed: 'c',
                      children: [StickyNoteContent(Text('small'))],
                    ),
                    StickyNote(
                      color: StickyColor.green,
                      done: false,
                      onDoneChange: (_) {},
                      forcedStates: const {InkState.hovered},
                      seed: 'live',
                      children: const [
                        StickyNoteTitle(Text('post the parcel')),
                        StickyNoteContent(Text('before the office shuts')),
                      ],
                    ),
                    const StickyNote(
                      done: true,
                      seed: 'loaded',
                      children: [
                        StickyNoteTitle(Text('ink pens')),
                        StickyNoteContent(Text('two fine, one brush')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/sticky-note-pads.png'),
    );
  });
}
