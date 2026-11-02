import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One scripted turn of the shadcn examples: yours (`mine`) or the
/// assistant's.
typedef MessageScrollerTurn = ({String id, bool mine, String text});

/// A turn as a [Message]: yours in a muted bubble on the end side, the
/// assistant's unframed on the start side, with blank lines splitting the
/// text into paragraphs 8 px apart.
class MessageScrollerTurnMessage extends StatelessWidget {
  const MessageScrollerTurnMessage({
    super.key,
    required this.turn,
    this.paragraphs = true,
    this.text,
  });

  final MessageScrollerTurn turn;

  /// Splits the text on blank lines.
  final bool paragraphs;

  /// Replaces the text, like a streaming [MessageText].
  final Widget? text;

  @override
  Widget build(BuildContext context) => Message(
    align: switch (turn.mine) {
      true => ChatAlign.end,
      false => ChatAlign.start,
    },
    children: [
      MessageContent(
        children: [
          Bubble(
            variant: switch (turn.mine) {
              true => BubbleVariant.muted,
              false => BubbleVariant.ghost,
            },
            children: [BubbleContent(child: text ?? _body())],
          ),
        ],
      ),
    ],
  );

  Widget _body() {
    if (!paragraphs) return Text(turn.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d8,
      children: [
        for (final paragraph in turn.text.split(RegExp(r'\n\s*\n')))
          Text(paragraph),
      ],
    );
  }
}

/// Cuts a long line to 42 characters for a menu, upstream's
/// `text.slice(0, 39)...`.
String messageScrollerShortLine(String text) => switch (text.length > 42) {
  true => '${text.substring(0, 39)}...',
  false => text,
};
