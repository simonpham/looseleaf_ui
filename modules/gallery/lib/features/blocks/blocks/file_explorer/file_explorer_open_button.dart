import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/file_explorer/file_explorer.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A file's icon and name as one button: it opens a folder or picks a
/// file. A highlighter wash lies under it on hover and focus (and while
/// [swiped]), like upstream's `hover:ll-swipe`.
class FileExplorerOpenButton extends StatelessWidget {
  const FileExplorerOpenButton({
    super.key,
    required this.item,
    required this.onPressed,
    this.grid = false,
    this.swiped = false,
    this.showMeta = false,
  });

  final FileExplorerItem item;
  final VoidCallback onPressed;

  /// Stacks a big doodled icon over the name, for the grid.
  final bool grid;

  /// Keeps the swipe on, for a picked card.
  final bool swiped;

  /// Shows the meta line under the name in the list (upstream `sm:hidden`).
  final bool showMeta;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final nameStyle = TextStyle(
      fontWeight: switch (item.isFolder) {
        true => FontWeight.w700,
        false => FontWeight.w400,
      },
    );
    final metaStyle = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    return InkInteraction(
      onActivate: onPressed,
      semantics: SemanticsProperties(
        button: true,
        label: '${item.name}${item.spoken}',
      ),
      builder: (context, states) {
        final active =
            swiped ||
            states.contains(InkState.hovered) ||
            states.contains(InkState.focused);
        Text name(TextAlign align) => Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: nameStyle,
        );

        if (grid) {
          return ExcludeSemantics(
            child: SidebarSwipe(
              on: active,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d6,
                  children: [
                    InkIcon(
                      item.node.kind.icon,
                      size: Spacing.d44,
                      tone: ArtTone.doodle,
                    ),
                    DefaultTextStyle.merge(
                      style: theme.typography.interface(
                        cssSize: 15,
                        color: theme.colors.ink,
                      ),
                      child: Center(child: name(TextAlign.center)),
                    ),
                    Text(
                      item.meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: metaStyle,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return ExcludeSemantics(
          child: SidebarSwipe(
            on: active,
            child: Row(
              spacing: Spacing.d10,
              children: [
                InkIcon(item.node.kind.icon, size: Spacing.d20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      name(TextAlign.start),
                      if (showMeta)
                        Text(
                          item.meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: metaStyle,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
