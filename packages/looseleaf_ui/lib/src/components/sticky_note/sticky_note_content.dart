import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sticky_note/sticky_note_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A sticky note's body, in the note's marker script. It grows to push a
/// [StickyNoteFooter] down, and is struck through once the note is done.
/// Use it as a direct child of a `StickyNote`.
///
/// Mirrors `StickyNoteContent` in upstream
/// `src/components/ui/sticky-note.tsx`.
class StickyNoteContent extends StatelessWidget {
  const StickyNoteContent(this.child, {super.key});

  /// The body, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final done = StickyNoteScope.doneOf(context);
    return Expanded(
      child: DefaultTextStyle.merge(
        style: TextStyle(
          decoration: switch (done) {
            true => TextDecoration.lineThrough,
            false => TextDecoration.none,
          },
          decorationColor: theme.colors.ink,
          decorationThickness: 1,
        ),
        child: Align(alignment: AlignmentDirectional.topStart, child: child),
      ),
    );
  }
}
