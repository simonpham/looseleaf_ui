import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/kanban_board/kanban_board.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Which arrow moved a note, so focus lands back on it.
enum KanbanDirection { back, forward }

/// A note on the board: its pad, title, who has it and when it is due,
/// with arrows to move it a column back or forward. Drag it to another
/// column too.
class KanbanBoardCard extends StatelessWidget {
  const KanbanBoardCard({
    super.key,
    required this.note,
    required this.onMove,
    this.takeFocus = false,
    this.focusVia,
  });

  final KanbanNote note;
  final void Function(String id, KanbanColumnId to, KanbanDirection? via)
  onMove;

  /// True when this note was just moved: one of its arrows takes focus.
  final bool takeFocus;

  /// The arrow that moved it, which takes focus when the note still has it.
  final KanbanDirection? focusVia;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      return Draggable<String>(
        data: note.id,
        feedback: Directionality(
          textDirection: Directionality.of(context),
          child: _Note(note: note, width: width, onMove: onMove),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: _Note(note: note, width: width, onMove: onMove),
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: _Note(
            note: note,
            width: width,
            onMove: onMove,
            takeFocus: takeFocus,
            focusVia: focusVia,
          ),
        ),
      );
    },
  );
}

class _Note extends StatelessWidget {
  const _Note({
    required this.note,
    required this.width,
    required this.onMove,
    this.takeFocus = false,
    this.focusVia,
  });

  final KanbanNote note;
  final double width;
  final void Function(String id, KanbanColumnId to, KanbanDirection? via)
  onMove;
  final bool takeFocus;
  final KanbanDirection? focusVia;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final back = note.column.back;
    final forward = note.column.forward;
    final focused = switch ((takeFocus, focusVia)) {
      (false, _) => null,
      (true, KanbanDirection.forward) when forward != null =>
        KanbanDirection.forward,
      _ when back != null => KanbanDirection.back,
      _ => KanbanDirection.forward,
    };
    final detail = note.detail;
    final due = note.due;
    return StickyNote(
      color: note.label.color,
      done: switch (note.column) {
        KanbanColumnId.done => true,
        _ => null,
      },
      fastener: switch (note.column) {
        KanbanColumnId.doing => FastenerKind.pin,
        _ => null,
      },
      seed: note.id,
      width: width,
      minHeight: Spacing.d48,
      children: [
        Text(
          note.label.title,
          style: theme.typography.face(
            KevinSansFace.type,
            cssSize: 12,
            cssLineHeight: 16 / 12,
            color: theme.colors.inkSoft,
          ),
        ),
        StickyNoteContent(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d4,
            children: [
              StickyNoteTitle(
                Text(
                  note.title,
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 24,
                    cssLineHeight: 1.05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (detail != null)
                Text(
                  detail,
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 18.4,
                    cssLineHeight: 1.25,
                  ),
                ),
            ],
          ),
        ),
        StickyNoteFooter(
          Row(
            spacing: Spacing.d8,
            children: [
              ExcludeSemantics(
                child: Avatar(
                  size: AvatarSize.sm,
                  ring: null,
                  children: [AvatarFallback(name: note.who)],
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: note.who.split(' ').first,
                    children: [
                      if (due != null)
                        TextSpan(
                          text: ' · due $due',
                          style: TextStyle(color: theme.colors.inkSoft),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (back != null)
                Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.iconSm,
                  autofocus: focused == KanbanDirection.back,
                  semanticLabel: 'Move “${note.title}” to ${back.title}',
                  onPressed: () => onMove(note.id, back, KanbanDirection.back),
                  child: const InkIcon('arrow-left'),
                ),
              if (forward != null)
                Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.iconSm,
                  autofocus: focused == KanbanDirection.forward,
                  semanticLabel: 'Move “${note.title}” to ${forward.title}',
                  onPressed: () =>
                      onMove(note.id, forward, KanbanDirection.forward),
                  child: const InkIcon('arrow-right'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
