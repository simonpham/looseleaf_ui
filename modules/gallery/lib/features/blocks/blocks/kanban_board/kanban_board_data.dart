import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A column of the launch-week board.
enum KanbanColumnId {
  todo('To do', 'Waiting for a pair of hands'),
  doing('Doing', 'Pinned up, in progress'),
  done('Done', 'Ticked off');

  const KanbanColumnId(this.title, this.hint);

  final String title;
  final String hint;

  /// The column before this one, if any.
  KanbanColumnId? get back => switch (this) {
    todo => null,
    doing => todo,
    done => doing,
  };

  /// The column after this one, if any.
  KanbanColumnId? get forward => switch (this) {
    todo => doing,
    doing => done,
    done => null,
  };
}

/// Which pad a note is torn from.
enum KanbanLabel {
  design('Design', StickyColor.pink),
  shop('Shop', StickyColor.orange),
  words('Words', StickyColor.green),
  studio('Studio', StickyColor.blue),
  admin('Admin', StickyColor.yellow);

  const KanbanLabel(this.title, this.color);

  final String title;
  final StickyColor color;
}

/// A sticky note on the board.
class KanbanNote {
  const KanbanNote({
    required this.id,
    required this.title,
    required this.label,
    required this.who,
    required this.column,
    this.detail,
    this.due,
  });

  final String id;
  final String title;
  final String? detail;
  final KanbanLabel label;
  final String who;
  final String? due;
  final KanbanColumnId column;

  KanbanNote movedTo(KanbanColumnId to) => KanbanNote(
    id: id,
    title: title,
    detail: detail,
    label: label,
    who: who,
    due: due,
    column: to,
  );
}

const kanbanTeam = ['Ada Lovelace', 'Jo Okafor', 'Mika Kobayashi', 'Sam Reyes'];

const kanbanNotes = [
  KanbanNote(
    id: 'n1',
    title: 'Order washi tape for the box',
    label: KanbanLabel.shop,
    who: 'Ada Lovelace',
    due: 'Sep 28',
    column: KanbanColumnId.todo,
  ),
  KanbanNote(
    id: 'n2',
    title: 'Write the newsletter',
    detail: 'Three paragraphs and a link to the journal.',
    label: KanbanLabel.words,
    who: 'Jo Okafor',
    due: 'Sep 29',
    column: KanbanColumnId.todo,
  ),
  KanbanNote(
    id: 'n3',
    title: 'Photograph the field notebooks',
    label: KanbanLabel.studio,
    who: 'Mika Kobayashi',
    due: 'Sep 30',
    column: KanbanColumnId.todo,
  ),
  KanbanNote(
    id: 'n4',
    title: 'Book the courier',
    label: KanbanLabel.admin,
    who: 'Sam Reyes',
    column: KanbanColumnId.todo,
  ),
  KanbanNote(
    id: 'n5',
    title: 'Print the price tags',
    detail: 'Kraft card, two hundred of them.',
    label: KanbanLabel.shop,
    who: 'Ada Lovelace',
    due: 'Sep 27',
    column: KanbanColumnId.doing,
  ),
  KanbanNote(
    id: 'n6',
    title: 'Draw the sticker sheet',
    detail: 'Nine stickers. One of them is a snail.',
    label: KanbanLabel.design,
    who: 'Mika Kobayashi',
    due: 'Sep 27',
    column: KanbanColumnId.doing,
  ),
  KanbanNote(
    id: 'n7',
    title: 'Fix the postal code field at checkout',
    label: KanbanLabel.admin,
    who: 'Sam Reyes',
    column: KanbanColumnId.doing,
  ),
  KanbanNote(
    id: 'n8',
    title: 'Choose the paper stock',
    label: KanbanLabel.design,
    who: 'Jo Okafor',
    column: KanbanColumnId.done,
  ),
  KanbanNote(
    id: 'n9',
    title: 'Name the new notebook',
    detail: 'It is called Margin.',
    label: KanbanLabel.words,
    who: 'Jo Okafor',
    column: KanbanColumnId.done,
  ),
  KanbanNote(
    id: 'n10',
    title: 'Order the shipping boxes',
    label: KanbanLabel.admin,
    who: 'Sam Reyes',
    column: KanbanColumnId.done,
  ),
];
