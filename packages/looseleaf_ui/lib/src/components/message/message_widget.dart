import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message/chat_align.dart';
import 'package:looseleaf_ui/src/components/message/message_content.dart';
import 'package:looseleaf_ui/src/components/message/message_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One message in a chat: an optional [MessageAvatar] beside a
/// [MessageContent] (header, bubbles, footer), on the [align] side.
/// [ChatAlign.end] (you) mirrors the row so the avatar sits at the end.
/// The text is 15 px.
///
/// ```dart
/// Message(
///   children: [
///     const MessageAvatar(child: Mascot(pose: 'write', size: 40)),
///     MessageContent(children: [
///       const MessageHeader(child: Text('Stubby')),
///       const Text('The failing test first.'),
///       const MessageFooter(child: Text('edited a minute ago')),
///     ]),
///   ],
/// )
/// ```
///
/// Mirrors `Message` in upstream `src/components/ui/message.tsx`.
class Message extends StatefulWidget {
  const Message({
    super.key,
    required this.children,
    this.align = ChatAlign.start,
  });

  /// Usually a [MessageAvatar] and a [MessageContent], which fills the row.
  final List<Widget> children;

  final ChatAlign align;

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  int _footers = 0;

  void _countFooter(int delta) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _footers += delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final children = [
      for (final child in widget.children)
        switch (child) {
          MessageContent() => Expanded(child: child),
          _ => child,
        },
    ];
    return ChatAlignScope(
      align: widget.align,
      child: MessageScope(
        align: widget.align,
        hasFooter: _footers > 0,
        countFooter: _countFooter,
        child: DefaultTextStyle.merge(
          style: theme.typography.face(KevinSansFace.hand, cssSize: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: Spacing.d8,
            children: switch (widget.align) {
              ChatAlign.start => children,
              ChatAlign.end => children.reversed.toList(),
            },
            mainAxisAlignment: switch (widget.align) {
              ChatAlign.start => MainAxisAlignment.start,
              ChatAlign.end => MainAxisAlignment.end,
            },
          ),
        ),
      ),
    );
  }
}
