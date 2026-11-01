import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message/chat_align.dart';

/// What a [Message] tells its parts: its side and whether it has a footer
/// (upstream's `group-has-data-[slot=message-footer]/message`), which each
/// [MessageFooter] reports through [countFooter].
class MessageScope extends InheritedWidget {
  const MessageScope({
    super.key,
    required this.align,
    required this.hasFooter,
    required this.countFooter,
    required super.child,
  });

  final ChatAlign align;

  /// Whether a [MessageFooter] is in the message.
  final bool hasFooter;

  /// Adds (1) or removes (-1) a footer from the message's count.
  final ValueChanged<int> countFooter;

  /// The enclosing message's scope, or null outside one.
  static MessageScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MessageScope>();

  @override
  bool updateShouldNotify(MessageScope oldWidget) =>
      oldWidget.align != align || oldWidget.hasFooter != hasFooter;
}
