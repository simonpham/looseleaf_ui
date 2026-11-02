import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/notes_app/notes_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The shelf on a binder-clipped pad: a new-page button, a search, the
/// notebooks as vertical tabs with their counts, and the pages of the
/// open notebook as index cards.
///
/// Mirrors `NotesAppNoteList` in upstream
/// `src/blocks/notes-app/components/notes-app-note-list.tsx`.
class NotesAppNoteList extends StatefulWidget {
  const NotesAppNoteList({
    super.key,
    required this.notes,
    required this.notebook,
    required this.onNotebookChange,
    required this.selectedId,
    required this.onSelect,
    required this.onNew,
  });

  final List<NotesAppNote> notes;
  final String notebook;
  final ValueChanged<String> onNotebookChange;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onNew;

  @override
  State<NotesAppNoteList> createState() => _NotesAppNoteListState();
}

class _NotesAppNoteListState extends State<NotesAppNoteList> {
  final _query = TextEditingController();

  static const double _tabsWidth = 112;
  static const double _compactBelow = 448;

  /// Below this shelf width the notebooks run along the top instead of
  /// down the side, so the cards keep room to be read.
  static const double _stackBelow = 360;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQuery);
  }

  @override
  void dispose() {
    _query
      ..removeListener(_onQuery)
      ..dispose();
    super.dispose();
  }

  void _onQuery() => setState(() {});

  Widget _pages(String query, {required bool compact}) {
    final lowered = query.toLowerCase();
    final name = notesAppNotebookName(widget.notebook);
    final rows = [
      for (final note in notesAppInNotebook(widget.notes, widget.notebook))
        if (lowered.isEmpty ||
            '${note.title} ${notesAppStripMarks(note.body)}'
                .toLowerCase()
                .contains(lowered))
          note,
    ];
    if (rows.isEmpty) {
      final searching = query.isNotEmpty;
      return Empty(
        seed: 'empty-${widget.notebook}',
        children: [
          EmptyHeader(
            children: [
              EmptyMedia(
                pose: switch (searching) {
                  true => 'search',
                  false => 'sleep',
                },
                size: 88,
              ),
              EmptyTitle(
                child: Text(switch (searching) {
                  true => 'No page says that',
                  false => 'Nothing here yet',
                }),
              ),
              EmptyDescription(
                child: Text(switch (searching) {
                  true => 'Try a shorter word than “$query”.',
                  false => '$name is a clean page waiting for a first line.',
                }),
              ),
            ],
          ),
          if (!searching)
            EmptyContent(
              children: [
                Button(
                  size: ButtonSize.sm,
                  onPressed: widget.onNew,
                  child: const Text('Start a page'),
                ),
              ],
            ),
        ],
      );
    }
    return Semantics(
      container: true,
      label: '$name pages',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          for (final note in rows)
            NotesAppNoteCard(
              key: ValueKey(note.id),
              note: note,
              selected: note.id == widget.selectedId,
              compact: compact,
              onSelect: () => widget.onSelect(note.id),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final query = _query.text.trim();
    return Paper(
      stock: StockName.pad,
      rules: RuleName.none,
      tiltDegrees: -0.3,
      fastener: FastenerKind.binderClip,
      seed: 'notes-shelf',
      padding: const EdgeInsets.only(top: Spacing.d24, bottom: Spacing.d12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < _stackBelow;
          final notebooks = TabsList(
            children: [
              for (final notebook in notesAppNotebooks)
                TabsTrigger(
                  value: notebook.id,
                  seed: 'nb-${notebook.id}',
                  child: Row(
                    mainAxisSize: switch (stacked) {
                      true => MainAxisSize.min,
                      false => MainAxisSize.max,
                    },
                    spacing: Spacing.d4,
                    children: [
                      Flexible(
                        fit: switch (stacked) {
                          true => FlexFit.loose,
                          false => FlexFit.tight,
                        },
                        child: Text(
                          notebook.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${notesAppInNotebook(widget.notes, notebook.id).length}',
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
                child: Row(
                  spacing: Spacing.d12,
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          'Notes',
                          style: theme.typography.face(
                            KevinSansFace.script,
                            cssSize: 27.2,
                            cssLineHeight: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Button(
                      size: ButtonSize.sm,
                      onPressed: widget.onNew,
                      leading: const InkIcon('plus'),
                      child: const Text('New page'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
                child: InputGroup(
                  children: [
                    const InputGroupAddon(child: InkIcon('search')),
                    InputGroupInput(
                      controller: _query,
                      placeholder: 'Search this notebook',
                      semanticLabel: 'Search this notebook',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: Spacing.d12,
                    end: Spacing.d4,
                  ),
                  child: Tabs(
                    orientation: switch (stacked) {
                      true => TabsOrientation.horizontal,
                      false => TabsOrientation.vertical,
                    },
                    value: widget.notebook,
                    onValueChange: widget.onNotebookChange,
                    spacing: Spacing.d8,
                    children: [
                      Semantics(
                        container: true,
                        label: 'Notebooks',
                        child: switch (stacked) {
                          true => notebooks,
                          false => SizedBox(
                            width: _tabsWidth,
                            child: notebooks,
                          ),
                        },
                      ),
                      Expanded(
                        child: TabsContent(
                          value: widget.notebook,
                          child: ScrollArea(
                            bleed: true,
                            child: _pages(
                              query,
                              compact: constraints.maxWidth < _compactBelow,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
