import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/chat_app/chat_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Who a conversation is with: Stubby for the assistant, initials for
/// people (or for [name], one person of a group).
///
/// Mirrors `ChatAppFace` in upstream
/// `src/blocks/chat-app/components/chat-app-face.tsx`.
class ChatAppFace extends StatelessWidget {
  const ChatAppFace({
    super.key,
    required this.conversation,
    this.size = Spacing.d36,
    this.name,
  });

  final ChatAppConversation conversation;
  final double size;
  final String? name;

  static const double _mascotScale = 1.25;

  @override
  Widget build(BuildContext context) {
    if (conversation.kind == ChatAppKind.assistant) {
      final draw = (size * _mascotScale).roundToDouble();
      return SizedBox.square(
        dimension: size,
        child: OverflowBox(
          maxWidth: draw,
          maxHeight: draw,
          child: Mascot(size: draw, seed: '${conversation.id}-face'),
        ),
      );
    }
    return Avatar(
      size: switch (size > Spacing.d36) {
        true => AvatarSize.lg,
        false => AvatarSize.regular,
      },
      seed: '${conversation.id}-${name ?? ''}',
      children: [AvatarFallback(name: name ?? conversation.name)],
    );
  }
}
