import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EmptyDropzoneExample extends StatefulWidget {
  const EmptyDropzoneExample({super.key});

  @override
  State<EmptyDropzoneExample> createState() => _EmptyDropzoneExampleState();
}

class _EmptyDropzoneExampleState extends State<EmptyDropzoneExample> {
  static const _picked = ['sketch.png', 'notes.pdf'];

  List<String> _files = const [];

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 512),
    child: Paper(
      tape: PaperTape.top,
      tapeKind: TapeKind.washiDots,
      seed: 'drop',
      padding: const EdgeInsets.all(Spacing.d20),
      child: Empty(
        seed: 'dropzone',
        framed: true,
        children: [
          EmptyHeader(
            children: [
              const EmptyMedia(doodle: 'paper-plane', size: 88),
              EmptyTitle(
                child: Text(switch (_files) {
                  [] => 'Drop files here',
                  _ => 'Ready to send',
                }),
              ),
              Semantics(
                liveRegion: true,
                child: EmptyDescription(
                  child: Text(switch (_files) {
                    [] => 'or choose them from your computer. PNG, JPG or PDF, up to 10 MB.',
                    final files => files.join(', '),
                  }),
                ),
              ),
            ],
          ),
          EmptyContent(
            children: [
              Button(
                leading: const InkIcon('upload'),
                onPressed: () => setState(() => _files = _picked),
                child: Text(switch (_files) {
                  [] => 'Choose files',
                  _ => 'Choose others',
                }),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
