import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

/// `min-h-[22rem]`.
const _minHeight = 352.0;

class NotebookTurningPagesExample extends StatelessWidget {
  const NotebookTurningPagesExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Semantics(
        container: true,
        label: 'The week',
        child: const Notebook(
          curl: true,
          defaultValue: 'mon',
          seed: 'week',
          minHeight: _minHeight,
          children: [
            NotebookPage(
              value: 'mon',
              children: [
                NotebookTitle(Text('Monday')),
                Text('Rain on the window.'),
                Text('Tea, then the outline.'),
              ],
            ),
            NotebookPage(
              value: 'tue',
              children: [
                NotebookTitle(Text('Tuesday')),
                Text('Wash the sky, wait.'),
                Text('Post the parcel by five.'),
              ],
            ),
            NotebookPage(
              value: 'wed',
              children: [
                NotebookTitle(Text('Wednesday')),
                Text('Hatch the shade.'),
                Text('Nothing else. Nothing.'),
              ],
            ),
            NotebookTurn(to: 'tue', semanticLabel: 'Next page'),
          ],
        ),
      ),
    ),
  );
}
