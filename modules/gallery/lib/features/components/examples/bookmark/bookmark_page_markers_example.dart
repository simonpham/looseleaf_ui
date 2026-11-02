import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BookmarkPageMarkersExample extends StatelessWidget {
  const BookmarkPageMarkersExample({super.key});

  static const _wide = 768.0;
  static const _minHeight = 160.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final sheets = [
      Stack(
        clipBehavior: Clip.none,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: _minHeight,
              minWidth: double.infinity,
            ),
            child: Paper(
              seed: 'marked',
              padding: const EdgeInsets.all(Spacing.d24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d8,
                children: [
                  Text(
                    'Chapter three',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 24,
                      cssLineHeight: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text('where the ribbon marks the page'),
                ],
              ),
            ),
          ),
          const PositionedDirectional(
            top: -Spacing.d4,
            end: Spacing.d24,
            child: BookmarkRibbon(seed: 'r1'),
          ),
        ],
      ),
      const Stack(
        clipBehavior: Clip.none,
        children: [
          Notebook(
            seed: 'nb',
            minHeight: _minHeight,
            children: [
              NotebookPage(
                children: [
                  NotebookTitle(Text('Marked')),
                  Text('a ribbon in the notebook'),
                ],
              ),
            ],
          ),
          PositionedDirectional(
            top: -Spacing.d4,
            end: Spacing.d40,
            child: BookmarkRibbon(tone: Accent.teal, seed: 'r2'),
          ),
        ],
      ),
    ];
    return Padding(
      padding: const EdgeInsets.all(Spacing.d24),
      child: LayoutBuilder(
        builder: (context, constraints) =>
            switch (constraints.maxWidth >= _wide) {
              true => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d48,
                children: [for (final sheet in sheets) Expanded(child: sheet)],
              ),
              false => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d48,
                children: sheets,
              ),
            },
      ),
    );
  }
}
