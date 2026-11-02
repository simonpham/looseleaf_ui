import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `@2xl`: two columns from this width.
const _twoColumns = 672.0;

class NotebookBindingsExample extends StatelessWidget {
  const NotebookBindingsExample({super.key});

  @override
  Widget build(BuildContext context) {
    const notebooks = [
      Notebook(
        pages: 2,
        seed: 'spiral',
        minHeight: Spacing.d256,
        children: [
          NotebookPage(
            children: [
              NotebookTitle(Text('Spiral')),
              Text('a coil for every hole'),
            ],
          ),
        ],
      ),
      Notebook(
        binding: NotebookBinding.rings,
        pages: 3,
        seed: 'rings',
        minHeight: Spacing.d256,
        children: [
          NotebookPage(
            children: [
              NotebookTitle(Text('Rings')),
              Text('rings on a steel strip'),
            ],
          ),
        ],
      ),
      Notebook(
        binding: NotebookBinding.stitched,
        tone: Accent.tomato,
        pages: 1,
        seed: 'stitched',
        minHeight: Spacing.d256,
        children: [
          NotebookPage(
            children: [
              NotebookTitle(Text('Stitched')),
              Text('a running thread'),
            ],
          ),
        ],
      ),
      Notebook(
        side: NotebookSide.top,
        tone: Accent.sky,
        seed: 'top',
        minHeight: Spacing.d256,
        children: [
          NotebookPage(
            children: [
              NotebookTitle(Text('Reporter pad')),
              Text('call the printer before ten'),
            ],
          ),
        ],
      ),
    ];
    return Padding(
      padding: const EdgeInsets.all(Spacing.d8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = switch (constraints.maxWidth < _twoColumns) {
            true => 1,
            false => 2,
          };
          final cellWidth =
              (constraints.maxWidth - Spacing.d40 * (columns - 1)) / columns;
          return Wrap(
            spacing: Spacing.d40,
            runSpacing: Spacing.d48,
            children: [
              for (final notebook in notebooks)
                SizedBox(width: cellWidth, child: notebook),
            ],
          );
        },
      ),
    );
  }
}
