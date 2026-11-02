import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/kanban_board/kanban_board.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A launch-week board: To do, Doing and Done on graph paper, each note a
/// sticky torn from its label's pad. Move a note with its arrows, drag it
/// to another column, write a new one or clear Done.
///
/// Mirrors upstream `src/blocks/kanban-board/page.tsx`.
class KanbanBoardBlock extends StatefulWidget {
  const KanbanBoardBlock({super.key});

  @override
  State<KanbanBoardBlock> createState() => _KanbanBoardBlockState();
}

class _KanbanBoardBlockState extends State<KanbanBoardBlock> {
  List<KanbanNote> _notes = kanbanNotes;
  String _message = '';
  ({String id, KanbanDirection? via})? _focus;

  static const double _proseWidth = 600;

  String _notesWord(int count) => switch (count) {
    1 => 'note',
    _ => 'notes',
  };

  void _move(String id, KanbanColumnId to, KanbanDirection? via) {
    final note = _notes.where((note) => note.id == id).firstOrNull;
    if (note == null || note.column == to) return;
    final count = _notes.where((note) => note.column == to).length + 1;
    setState(() {
      _focus = (id: id, via: via);
      _notes = [
        for (final other in _notes)
          if (other.id != id) other,
        note.movedTo(to),
      ];
      _message =
          'Moved “${note.title}” to ${to.title}. ${to.title} has $count ${_notesWord(count)}.';
    });
  }

  void _add(KanbanColumnId column, String title, KanbanLabel label) {
    final next =
        _notes
            .map((note) => int.tryParse(note.id.substring(1)) ?? 0)
            .fold(
              0,
              (most, id) => switch (id > most) {
                true => id,
                false => most,
              },
            ) +
        1;
    setState(() {
      _focus = null;
      _notes = [
        ..._notes,
        KanbanNote(
          id: 'n$next',
          title: title,
          label: label,
          who: kanbanTeam.first,
          column: column,
        ),
      ];
      _message = 'Added “$title” to ${column.title}.';
    });
  }

  void _clearDone() {
    final count = _notes
        .where((note) => note.column == KanbanColumnId.done)
        .length;
    setState(() {
      _focus = null;
      _notes = [
        for (final note in _notes)
          if (note.column != KanbanColumnId.done) note,
      ];
      _message = 'Cleared $count done ${_notesWord(count)}.';
    });
  }

  Widget _column(KanbanColumnId column) => KanbanBoardColumn(
    column: column,
    notes: [
      for (final note in _notes)
        if (note.column == column) note,
    ],
    focus: _focus,
    onMove: _move,
    onAdd: (title, label) => _add(column, title, label),
    onClear: switch (column) {
      KanbanColumnId.done => _clearDone,
      _ => null,
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = width >= 640;
        final columns = [
          for (final column in KanbanColumnId.values) _column(column),
        ];
        final board = Padding(
          padding: EdgeInsets.all(switch (width) {
            >= 1024 => Spacing.d32,
            >= 640 => Spacing.d24,
            _ => Spacing.d16,
          }),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d24,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: Spacing.d16,
                runSpacing: Spacing.d16,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _proseWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.d4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: Spacing.d12,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                'Launch week',
                                style: theme.typography.face(
                                  KevinSansFace.script,
                                  cssSize: switch (wide) {
                                    true => 48,
                                    false => 36,
                                  },
                                  cssLineHeight: 1,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colors.ink,
                                ),
                              ),
                            ),
                            if (wide)
                              const Sticker(
                                'rocket',
                                size: 64,
                                seed: 'kanban-rocket',
                              ),
                          ],
                        ),
                        Text(
                          'Six days to the autumn drop. Move a note with its arrows, pick it up and drop it, or write a new one.',
                          style: theme.typography.interface(
                            color: theme.colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    container: true,
                    label: 'On this board',
                    child: AvatarGroup(
                      children: [
                        for (final name in kanbanTeam)
                          Avatar(children: [AvatarFallback(name: name)]),
                      ],
                    ),
                  ),
                ],
              ),
              switch (width >= 768) {
                true => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d16,
                  children: [
                    for (final column in columns) Expanded(child: column),
                  ],
                ),
                false => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d16,
                  children: columns,
                ),
              },
            ],
          ),
        );
        return Stack(
          children: [
            board,
            Semantics(
              liveRegion: true,
              label: _message,
              child: const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
