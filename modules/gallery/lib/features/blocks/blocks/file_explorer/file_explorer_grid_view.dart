import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/file_explorer/file_explorer.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The folder as index cards, [columns] to a row: a tick box and a menu
/// in the top corners, a big doodled icon, the name and its meta.
class FileExplorerGridView extends StatelessWidget {
  const FileExplorerGridView({
    super.key,
    required this.items,
    required this.selected,
    required this.columns,
    required this.onActivate,
    required this.onSelect,
    required this.onDelete,
  });

  final List<FileExplorerItem> items;
  final Set<String> selected;
  final int columns;
  final ValueChanged<FileExplorerItem> onActivate;
  final void Function(String id, bool on) onSelect;
  final ValueChanged<FileExplorerItem> onDelete;

  static const double _gap = Spacing.d16;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;
      return Wrap(
        spacing: _gap,
        runSpacing: _gap,
        children: [
          for (final item in items)
            SizedBox(
              width: width,
              child: _Card(
                item: item,
                picked: selected.contains(item.id),
                onActivate: onActivate,
                onSelect: onSelect,
                onDelete: onDelete,
              ),
            ),
        ],
      );
    },
  );
}

class _Card extends StatelessWidget {
  const _Card({
    required this.item,
    required this.picked,
    required this.onActivate,
    required this.onSelect,
    required this.onDelete,
  });

  final FileExplorerItem item;
  final bool picked;
  final ValueChanged<FileExplorerItem> onActivate;
  final void Function(String id, bool on) onSelect;
  final ValueChanged<FileExplorerItem> onDelete;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      Paper(
        stock: StockName.indexCard,
        rules: RuleName.none,
        seed: item.id,
        padding: const EdgeInsets.fromLTRB(
          Spacing.d12,
          Spacing.d32,
          Spacing.d12,
          Spacing.d12,
        ),
        child: FileExplorerOpenButton(
          item: item,
          grid: true,
          swiped: picked,
          onPressed: () => onActivate(item),
        ),
      ),
      PositionedDirectional(
        start: Spacing.d10,
        top: Spacing.d10,
        child: Checkbox(
          semanticLabel: 'Select ${item.name}',
          value: picked,
          onChanged: (on) => onSelect(item.id, on == true),
        ),
      ),
      PositionedDirectional(
        end: Spacing.d4,
        top: Spacing.d4,
        child: FileExplorerRowMenu(
          item: item,
          onActivate: onActivate,
          onDelete: onDelete,
        ),
      ),
    ],
  );
}
