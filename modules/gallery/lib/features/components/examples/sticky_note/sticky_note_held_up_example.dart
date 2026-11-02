import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickyNoteHeldUpExample extends StatelessWidget {
  const StickyNoteHeldUpExample({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(Spacing.d24),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: Spacing.d40,
      runSpacing: Spacing.d40,
      children: [
        StickyNote(
          curl: true,
          fastener: FastenerKind.pin,
          seed: 'a',
          children: [
            StickyNoteTitle(Text('pinned')),
            StickyNoteContent(Text('a curl, and a tomato pin')),
          ],
        ),
        StickyNote(
          color: StickyColor.blue,
          tape: PaperTape.top,
          seed: 'b',
          width: Spacing.d176 + Spacing.d48,
          children: [
            StickyNoteTitle(Text('taped')),
            StickyNoteContent(Text('a strip of masking tape across the top')),
            StickyNoteFooter(Text('from Ada')),
          ],
        ),
        StickyNote(
          color: StickyColor.green,
          seed: 'c',
          width: Spacing.d128,
          height: Spacing.d112,
          minHeight: 0,
          children: [StickyNoteContent(Text('small'))],
        ),
        StickyNote(
          color: StickyColor.pink,
          seed: 'd',
          width: Spacing.d256 + Spacing.d32,
          minHeight: Spacing.d112,
          children: [
            StickyNoteContent(
              Text(
                'a wide one, because notes can be any size you cut them to',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
