import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/notes_app/notes_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A note's body as written: the marked words highlighted, underlined,
/// circled or crossed out by hand.
///
/// Mirrors `NotesAppMarked` in upstream
/// `src/blocks/notes-app/components/notes-app-marked.tsx`.
class NotesAppMarked extends StatelessWidget {
  const NotesAppMarked({super.key, required this.body, required this.seed});

  final String body;
  final String seed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final style = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 17,
      cssLineHeight: 28 / 17,
    );
    return DefaultTextStyle.merge(
      style: style,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, line) in body.split('\n').indexed)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Spacing.d28),
              child: Text.rich(
                TextSpan(
                  children: [
                    for (final (j, piece) in notesAppParseLine(line).indexed)
                      switch (piece.mark) {
                        null => TextSpan(text: piece.text),
                        final mark => WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: Annotate(
                            type: mark.type,
                            color: mark.color,
                            kind: mark.kind,
                            seed: '$seed:$i:$j',
                            child: Text(piece.text),
                          ),
                        ),
                      },
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
