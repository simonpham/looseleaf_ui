import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message/message_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A quiet hand note above a message's bubbles: the speaker's name, a
/// time. 14 px bold muted text, 12 px in from the bubble's edge (flush beside a ghost bubble).
///
/// Mirrors `MessageHeader` in upstream `src/components/ui/message.tsx`.
class MessageHeader extends StatelessWidget {
  const MessageHeader({super.key, required this.child});

  /// The note; a [Row] of parts is laid out 8 px apart by the caller.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: switch (MessageScope.maybeOf(context)?.hasGhost ?? false) {
        true => EdgeInsets.zero,
        false => const EdgeInsets.symmetric(horizontal: Spacing.d12),
      },
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 14,
          cssLineHeight: 20 / 14,
          fontWeight: FontWeight.w700,
          color: theme.colors.inkMuted,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: theme.colors.inkMuted),
          child: child,
        ),
      ),
    );
  }
}
