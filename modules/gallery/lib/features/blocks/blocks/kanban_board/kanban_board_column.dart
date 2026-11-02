import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/kanban_board/kanban_board.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One column of the board on graph paper: its title, hint and tally, the
/// notes in it, and a way to write a new one. Notes dragged over it are
/// dropped into it; Done can be cleared.
class KanbanBoardColumn extends StatefulWidget {
  const KanbanBoardColumn({
    super.key,
    required this.column,
    required this.notes,
    required this.onMove,
    required this.onAdd,
    this.focus,
    this.onClear,
  });

  final KanbanColumnId column;
  final List<KanbanNote> notes;
  final void Function(String id, KanbanColumnId to, KanbanDirection? via)
  onMove;
  final void Function(String title, KanbanLabel label) onAdd;

  /// The note that was just moved here and the arrow that moved it.
  final ({String id, KanbanDirection? via})? focus;

  final VoidCallback? onClear;

  @override
  State<KanbanBoardColumn> createState() => _KanbanBoardColumnState();
}

class _KanbanBoardColumnState extends State<KanbanBoardColumn> {
  bool _over = false;

  String _count(int count) => switch (count) {
    1 => '1 note',
    _ => '$count notes',
  };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final column = widget.column;
    final notes = widget.notes;
    final onClear = widget.onClear;
    final focus = widget.focus;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: column.title,
      child: Paper(
        stock: StockName.graph,
        tilt: false,
        seed: 'kanban-${column.name}',
        padding: const EdgeInsets.all(Spacing.d16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d12,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d8,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          column.title,
                          style: theme.typography.face(
                            KevinSansFace.script,
                            cssSize: 30.4,
                            cssLineHeight: 1,
                            fontWeight: FontWeight.w700,
                            color: theme.colors.ink,
                          ),
                        ),
                      ),
                      Text(
                        column.hint,
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onClear != null && notes.isNotEmpty)
                  Button(
                    variant: ButtonVariant.ghost,
                    size: ButtonSize.sm,
                    semanticLabel:
                        'Clear the ${notes.length} done ${switch (notes.length) {
                          1 => 'note',
                          _ => 'notes',
                        }}',
                    onPressed: onClear,
                    child: const Text('Clear'),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.d4),
                  child: Tally(
                    count: notes.length,
                    seed: 'kanban-tally-${column.name}',
                    label: _count(notes.length),
                  ),
                ),
              ],
            ),
            DragTarget<String>(
              onWillAcceptWithDetails: (details) {
                setState(() => _over = true);
                return true;
              },
              onLeave: (_) => setState(() => _over = false),
              onAcceptWithDetails: (details) {
                setState(() => _over = false);
                widget.onMove(details.data, column, null);
              },
              builder: (context, candidates, rejected) => CustomPaint(
                foregroundPainter: switch (_over) {
                  true => _DashedOutline(theme.colors.inkYou),
                  false => null,
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Spacing.d160),
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.d4),
                    child: switch (notes) {
                      [] => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.d24,
                        ),
                        child: Text(
                          'Nothing here yet. Drop a note, or write a new one.',
                          textAlign: TextAlign.center,
                          style: theme.typography.interface(
                            cssSize: 14,
                            color: theme.colors.inkMuted,
                          ),
                        ),
                      ),
                      _ => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Spacing.d16,
                        children: [
                          for (final note in notes)
                            KanbanBoardCard(
                              key: ValueKey(note.id),
                              note: note,
                              onMove: widget.onMove,
                              takeFocus: focus?.id == note.id,
                              focusVia: focus?.via,
                            ),
                        ],
                      ),
                    },
                  ),
                ),
              ),
            ),
            KanbanBoardAddNote(column: column.title, onAdd: widget.onAdd),
          ],
        ),
      ),
    );
  }
}

/// Upstream's `outline-2 outline-dashed outline-offset-2 outline-ink-you`
/// on the column a note is dragged over.
class _DashedOutline extends CustomPainter {
  const _DashedOutline(this.color);

  final Color color;

  static const double _dash = Spacing.d6;
  static const double _offset = Spacing.d3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = Spacing.d2;
    final rect = (Offset.zero & size).inflate(_offset);
    final path = Path()..addRect(rect);
    for (final PathMetric metric in path.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += _dash * 2) {
        canvas.drawPath(metric.extractPath(at, at + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedOutline oldDelegate) => oldDelegate.color != color;
}
