import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _shelf = [
  (tone: Accent.tomato, name: 'Field notes', band: true),
  (tone: Accent.teal, name: 'Recipes', band: true),
  (tone: Accent.sky, name: 'Sketches', band: true),
  (tone: Accent.grape, name: 'Letters', band: false),
  (tone: null, name: 'Accounts', band: true),
];

class NotebookCoversExample extends StatelessWidget {
  const NotebookCoversExample({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d8),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: Spacing.d24,
      runSpacing: Spacing.d32,
      children: [
        for (final notebook in _shelf)
          NotebookCover(
            tone: notebook.tone,
            band: notebook.band,
            seed: notebook.name,
            semanticLabel: '${notebook.name} notebook',
            child: NotebookCoverLabel(Text(notebook.name)),
          ),
      ],
    ),
  );
}
