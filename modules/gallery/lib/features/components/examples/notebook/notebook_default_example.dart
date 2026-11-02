import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

/// `min-h-[24rem]`.
const _minHeight = 384.0;

class NotebookDefaultExample extends StatelessWidget {
  const NotebookDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final muted = TextStyle(color: theme.colors.inkMuted);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Notebook(
          seed: 'field-notes',
          minHeight: _minHeight,
          children: [
            NotebookPage(
              children: [
                const NotebookTitle(Text('Field notes')),
                const Text('Tuesday. Rain on the window,'),
                const Text('three cups of tea, and one'),
                const Text('very small plan for a very big week.'),
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.d28),
                  child: Text('1. ink the outline', style: muted),
                ),
                Text('2. wash the sky, then wait', style: muted),
                Text('3. hatch the shade', style: muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
