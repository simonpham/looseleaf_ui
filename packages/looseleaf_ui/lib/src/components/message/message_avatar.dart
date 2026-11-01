import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message/message_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The speaker's face beside a [Message]: at least 32 px wide, at the
/// bottom of the row. When the message has a [MessageFooter] it rides up
/// past it, so it stands beside the last bubble.
///
/// Mirrors `MessageAvatar` in upstream `src/components/ui/message.tsx`.
class MessageAvatar extends StatelessWidget {
  const MessageAvatar({super.key, required this.child});

  /// An [Avatar], a [Mascot] or any small picture.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final avatar = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: Spacing.d32),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
    final lifted = MessageScope.maybeOf(context)?.hasFooter ?? false;
    if (!lifted) return avatar;
    return Transform.translate(
      offset: const Offset(0, -Spacing.d32),
      child: avatar,
    );
  }
}
