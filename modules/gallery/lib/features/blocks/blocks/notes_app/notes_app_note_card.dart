import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/notes_app/notes_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A page on the shelf as an index card: its title, the first lines, its
/// notebook and when it changed. The open one wears a lemon flag; the
/// whole card opens it.
///
/// Mirrors `NoteCard` in upstream
/// `src/blocks/notes-app/components/notes-app-note-list.tsx`.
class NotesAppNoteCard extends StatelessWidget {
  const NotesAppNoteCard({
    super.key,
    required this.note,
    required this.selected,
    required this.compact,
    required this.onSelect,
  });

  final NotesAppNote note;
  final bool selected;

  /// Sets the title smaller, for a narrow shelf.
  final bool compact;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final title = switch (note.title.isEmpty) {
      true => 'Untitled',
      false => note.title,
    };
    final preview = notesAppStripMarks(
      note.body,
    ).replaceAll(RegExp(r'\s+'), ' ').trim();
    return InkInteraction(
      onActivate: onSelect,
      semantics: SemanticsProperties(
        button: true,
        selected: selected,
        label: 'Open $title',
      ),
      builder: (context, states) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: switch (states.contains(InkState.focused)) {
            true => Border.all(color: theme.colors.focus, width: Spacing.d2),
            false => null,
          },
        ),
        child: IndexCard(
          seed: note.id,
          flag: switch (selected) {
            true => Accent.lemon,
            false => null,
          },
          minHeight: Spacing.d28,
          maxWidth: double.infinity,
          children: [
            IndexCardHeader(
              children: [
                IndexCardTitle(
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: switch (compact) {
                        true =>
                          theme.typography
                              .face(KevinSansFace.script, cssSize: 20.8)
                              .fontSize,
                        false =>
                          theme.typography
                              .face(KevinSansFace.script, cssSize: 24)
                              .fontSize,
                      },
                    ),
                  ),
                ),
              ],
            ),
            IndexCardContent(
              children: [
                Text(
                  switch (preview.isEmpty) {
                    true => 'Nothing written yet.',
                    false => preview,
                  },
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.face(KevinSansFace.hand, cssSize: 15),
                ),
              ],
            ),
            IndexCardFooter(
              children: [
                Expanded(
                  child: Text(
                    notesAppNotebookName(note.notebook),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(note.updated),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
