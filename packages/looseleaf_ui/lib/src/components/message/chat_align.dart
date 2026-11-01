import 'package:flutter/widgets.dart';

/// Which side of a chat a message sits on: [start] for others, [end] for
/// you.
///
/// Mirrors `ChatAlign` in upstream `src/lib/chat-align.ts`.
enum ChatAlign { start, end }

/// Tells the chat parts below (a bubble's tail, a message's footer) which
/// side their message sits on. A [Message] provides it.
///
/// Mirrors `ChatAlignContext` in upstream `src/lib/chat-align.ts`.
class ChatAlignScope extends InheritedWidget {
  const ChatAlignScope({super.key, required this.align, required super.child});

  final ChatAlign align;

  /// The side of the enclosing message, or null outside one.
  static ChatAlign? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChatAlignScope>()?.align;

  @override
  bool updateShouldNotify(ChatAlignScope oldWidget) => oldWidget.align != align;
}
