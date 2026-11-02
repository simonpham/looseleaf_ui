import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickyNoteDoneExample extends StatefulWidget {
  const StickyNoteDoneExample({super.key});

  @override
  State<StickyNoteDoneExample> createState() => _StickyNoteDoneExampleState();
}

class _StickyNoteDoneExampleState extends State<StickyNoteDoneExample> {
  bool _done = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d24),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: Spacing.d40,
      runSpacing: Spacing.d40,
      children: [
        StickyNote(
          color: StickyColor.green,
          done: _done,
          onDoneChange: (done) => setState(() => _done = done),
          seed: 'live',
          children: const [
            StickyNoteTitle(Text('post the parcel')),
            StickyNoteContent(Text('before the office shuts. Press the box.')),
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
  );
}
