import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EmptyIconTileExample extends StatelessWidget {
  const EmptyIconTileExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Empty(
      seed: 'no-projects',
      children: [
        const EmptyHeader(
          children: [
            EmptyMedia(
              variant: EmptyMediaVariant.icon,
              child: InkIcon('folder-plus'),
            ),
            EmptyTitle(child: Text('No projects yet')),
            EmptyDescription(
              child: Text(
                'You have not created any projects yet. Get started by creating your first project.',
              ),
            ),
          ],
        ),
        EmptyContent(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d8,
              children: [
                Button(onPressed: () {}, child: const Text('Create project')),
                Button(
                  variant: ButtonVariant.outline,
                  onPressed: () {},
                  child: const Text('Import project'),
                ),
              ],
            ),
            Button(
              variant: ButtonVariant.link,
              size: ButtonSize.sm,
              trailing: const InkIcon('arrow-up-right'),
              onPressed: () {},
              child: Text(
                'Learn more',
                style: TextStyle(color: theme.colors.inkMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
