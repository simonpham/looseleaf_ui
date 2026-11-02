import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BookmarkReadingListExample extends StatefulWidget {
  const BookmarkReadingListExample({super.key});

  @override
  State<BookmarkReadingListExample> createState() =>
      _BookmarkReadingListExampleState();
}

class _BookmarkReadingListExampleState
    extends State<BookmarkReadingListExample> {
  static const _maxWidth = Spacing.d384;
  static const _articles = [
    (
      id: 'margin',
      title: 'Why the margin is the best part',
      meta: 'Notebook - 4 min',
    ),
    (id: 'paper', title: 'On paper that has tooth', meta: 'Materials - 6 min'),
    (id: 'hands', title: 'Nothing is drawn straight', meta: 'Craft - 3 min'),
  ];

  final _saved = <String>{'paper'};

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d32,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                'Saved for later: ${_saved.length} of ${_articles.length}',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 24,
                  color: theme.colors.ink,
                ),
              ),
            ),
            for (final (index, article) in _articles.indexed)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Card(
                    stock: StockName.indexCard,
                    seed: article.id,
                    tiltDegrees: switch (index.isOdd) {
                      true => 0.2,
                      false => -0.2,
                    },
                    gap: Spacing.d4,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.d20),
                    children: [
                      CardHeader(
                        padding: const EdgeInsetsDirectional.only(
                          start: Spacing.d24,
                          end: Spacing.d64,
                        ),
                        children: [
                          CardTitle(Text(article.title)),
                          CardDescription(Text(article.meta)),
                        ],
                      ),
                    ],
                  ),
                  PositionedDirectional(
                    top: -Spacing.d4,
                    end: Spacing.d24,
                    child: Bookmark(
                      tone: switch (index) {
                        1 => Accent.teal,
                        _ => Accent.tomato,
                      },
                      seed: article.id,
                      value: _saved.contains(article.id),
                      onChanged: (value) => setState(() {
                        if (value) {
                          _saved.add(article.id);
                          return;
                        }
                        _saved.remove(article.id);
                      }),
                      semanticLabel: 'Save: ${article.title}',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
