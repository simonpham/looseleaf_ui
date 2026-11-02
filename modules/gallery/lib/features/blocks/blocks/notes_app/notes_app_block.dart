import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/notes_app/notes_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A notes app: notebooks and their pages on a binder-clipped shelf, the
/// open page in a spiral notebook to read or write in, with hand-drawn
/// marks, a tally of reads and a way to tear a page out. Below 896 px the
/// shelf and the page take turns.
///
/// Mirrors upstream `src/blocks/notes-app/page.tsx`.
class NotesAppBlock extends StatefulWidget {
  const NotesAppBlock({super.key, this.onNotesChange});

  /// Called with every page after each change.
  final ValueChanged<List<NotesAppNote>>? onNotesChange;

  @override
  State<NotesAppBlock> createState() => _NotesAppBlockState();
}

class _NotesAppBlockState extends State<NotesAppBlock> {
  List<NotesAppNote> _notes = notesAppNotes;
  String _notebook = notesAppAll;
  String? _selectedId = notesAppFeatured;
  NotesAppMode _mode = NotesAppMode.page;
  bool _showEditor = false;
  int _counter = 0;

  static const double _wideFrom = 896;
  static const double _height = 768;
  static const double _minShelfWidth = 320;
  static const double _maxShelfWidth = 384;
  static const double _shelfShare = 0.4;

  void _commit(List<NotesAppNote> notes) {
    _notes = notes;
    widget.onNotesChange?.call(notes);
  }

  void _open(String id) => setState(() {
    _selectedId = id;
    _mode = NotesAppMode.page;
    _showEditor = true;
  });

  void _create() {
    final id = 'page-${_counter++}';
    setState(() {
      _commit([
        NotesAppNote(
          id: id,
          notebook: switch (_notebook) {
            notesAppAll => 'scraps',
            final notebook => notebook,
          },
          title: '',
          body: '',
          updated: 'just now',
          reads: 0,
        ),
        ..._notes,
      ]);
      _selectedId = id;
      _mode = NotesAppMode.write;
      _showEditor = true;
    });
  }

  void _change(NotesAppNote changed) => setState(
    () => _commit([
      for (final note in _notes)
        switch (note.id == changed.id) {
          true => changed,
          false => note,
        },
    ]),
  );

  void _remove() => setState(() {
    final rest = [
      for (final note in _notes)
        if (note.id != _selectedId) note,
    ];
    _commit(rest);
    _selectedId = notesAppInNotebook(rest, _notebook).firstOrNull?.id;
    _mode = NotesAppMode.page;
    _showEditor = false;
  });

  @override
  Widget build(BuildContext context) {
    final note = _notes.where((each) => each.id == _selectedId).firstOrNull;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideFrom;
        final shelf = NotesAppNoteList(
          notes: _notes,
          notebook: _notebook,
          onNotebookChange: (notebook) => setState(() => _notebook = notebook),
          selectedId: _selectedId,
          onSelect: _open,
          onNew: _create,
        );
        final page = switch (note) {
          null => const Paper(
            stock: StockName.card,
            child: Center(
              child: Empty(
                seed: 'no-page',
                children: [
                  EmptyHeader(
                    children: [
                      EmptyMedia(pose: 'idle', size: 104),
                      EmptyTitle(child: Text('Pick a page')),
                      EmptyDescription(
                        child: Text(
                          'Open one from the shelf, or start a new page with the button up there.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          final note => NotesAppEditor(
            key: ValueKey(note.id),
            note: note,
            notebookName: notesAppNotebookName(note.notebook),
            mode: _mode,
            onModeChange: (mode) => setState(() => _mode = mode),
            onChange: _change,
            onDelete: _remove,
            onBack: () => setState(() => _showEditor = false),
            wide: wide,
          ),
        };
        return SizedBox(
          height: _height,
          child: Padding(
            padding: switch (wide) {
              true => const EdgeInsets.fromLTRB(
                Spacing.d24,
                Spacing.d48,
                Spacing.d24,
                Spacing.d24,
              ),
              false => const EdgeInsets.fromLTRB(
                Spacing.d16,
                Spacing.d40,
                Spacing.d16,
                Spacing.d16,
              ),
            },
            child: switch (wide) {
              true => Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d24,
                children: [
                  SizedBox(
                    width: (constraints.maxWidth * _shelfShare).clamp(
                      _minShelfWidth,
                      _maxShelfWidth,
                    ),
                    child: shelf,
                  ),
                  Expanded(child: page),
                ],
              ),
              false => switch (_showEditor) {
                true => page,
                false => shelf,
              },
            },
          ),
        );
      },
    );
  }
}
