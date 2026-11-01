import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message/chat_align.dart';

/// What a [Message] tells its parts: its side, whether it has a footer
/// (upstream's `group-has-data-[slot=message-footer]/message`), which each
/// [MessageFooter] reports through [countFooter], and whether it holds a
/// ghost bubble (`group-has-data-[variant=ghost]/message`), which each
/// [MessageGhost] reports through [countGhost].
class MessageScope extends InheritedWidget {
  const MessageScope({
    super.key,
    required this.align,
    required this.hasFooter,
    required this.countFooter,
    this.hasGhost = false,
    this.countGhost,
    required super.child,
  });

  final ChatAlign align;

  /// Whether a [MessageFooter] is in the message.
  final bool hasFooter;

  /// Adds (1) or removes (-1) a footer from the message's count.
  final ValueChanged<int> countFooter;

  /// Whether a ghost bubble is in the message: its header and footer then
  /// line up with the bare words instead of a bubble's padding.
  final bool hasGhost;

  /// Adds (1) or removes (-1) a ghost bubble from the message's count.
  final ValueChanged<int>? countGhost;

  /// The enclosing message's scope, or null outside one.
  static MessageScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MessageScope>();

  @override
  bool updateShouldNotify(MessageScope oldWidget) =>
      oldWidget.align != align ||
      oldWidget.hasFooter != hasFooter ||
      oldWidget.hasGhost != hasGhost;
}
