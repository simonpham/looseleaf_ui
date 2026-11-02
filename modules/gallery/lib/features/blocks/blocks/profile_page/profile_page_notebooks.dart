import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/profile_page/profile_page.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The Notebooks tab: the shelf of covers with their page counts.
class ProfilePageNotebooks extends StatelessWidget {
  const ProfilePageNotebooks({
    super.key,
    required this.shelf,
    required this.width,
  });

  final List<ProfilePageNotebook> shelf;

  /// The page's content width, for upstream's `@container/profile` queries.
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      label: 'Notebooks',
      child: Wrap(
        spacing: Spacing.d32,
        runSpacing: Spacing.d40,
        alignment: switch (width >= 448) {
          true => WrapAlignment.start,
          false => WrapAlignment.center,
        },
        children: [
          for (final notebook in shelf)
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d12,
              children: [
                NotebookCover(
                  tone: notebook.tone,
                  band: notebook.name != 'Letters',
                  seed: notebook.name,
                  semanticLabel: '${notebook.name} notebook',
                  child: NotebookCoverLabel(Text(notebook.name)),
                ),
                Text(
                  '${notebook.pages} pages',
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
