import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FolderStocksExample extends StatelessWidget {
  const FolderStocksExample({super.key});

  static const _narrow = 320.0;

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(Spacing.d8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d48,
      children: [
        Folder(
          stock: StockName.stickyYellow,
          defaultValue: 'one',
          maxWidth: _narrow,
          children: [
            FolderTabs(
              semanticLabel: 'Recipes',
              children: [FolderTab(value: 'one', child: Text('Recipes'))],
            ),
            FolderContent(
              value: 'one',
              seed: 'y',
              tape: PaperTape.top,
              child: Text('A folder with one tab is just a labeled folder.'),
            ),
          ],
        ),
        Folder(
          stock: StockName.paper,
          defaultValue: 'c',
          children: [
            FolderTabs(
              semanticLabel: 'Photos',
              children: [
                FolderTab(value: 'a', child: Text('Sketches')),
                FolderTab(value: 'b', child: Text('Notes')),
                FolderTab(value: 'c', child: Text('Photos')),
              ],
            ),
            FolderContent(value: 'a', seed: 'a', child: Text('Sketches')),
            FolderContent(value: 'b', seed: 'b', child: Text('Notes')),
            FolderContent(
              value: 'c',
              seed: 'c',
              child: Text('White card, three tabs, the last one open.'),
            ),
          ],
        ),
      ],
    ),
  );
}
