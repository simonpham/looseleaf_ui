import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message/chat_align.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The body of a [Message]: header, bubbles and footer stacked 10 px
/// apart, each at its message's side. Inside a [Message] it fills the row.
///
/// Mirrors `MessageContent` in upstream `src/components/ui/message.tsx`.
class MessageContent extends StatelessWidget {
  const MessageContent({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: switch (ChatAlignScope.maybeOf(context)) {
      ChatAlign.end => CrossAxisAlignment.end,
      _ => CrossAxisAlignment.start,
    },
    spacing: Spacing.d10,
    children: children,
  );
}
