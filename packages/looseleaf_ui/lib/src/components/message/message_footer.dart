import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message/message_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A quiet hand note under a message's bubbles: edited, seen, a time.
/// 14 px muted text, 12 px in from the bubble's edge (flush beside a ghost bubble). Its message's
/// [MessageAvatar] rides above it.
///
/// Mirrors `MessageFooter` in upstream `src/components/ui/message.tsx`.
class MessageFooter extends StatefulWidget {
  const MessageFooter({super.key, required this.child});

  final Widget child;

  @override
  State<MessageFooter> createState() => _MessageFooterState();
}

class _MessageFooterState extends State<MessageFooter> {
  ValueChanged<int>? _counted;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final count = MessageScope.maybeOf(context)?.countFooter;
    if (count == _counted) return;
    _counted?.call(-1);
    _counted = count;
    count?.call(1);
  }

  @override
  void dispose() {
    _counted?.call(-1);
    super.dispose();
  }

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
          color: theme.colors.inkMuted,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: theme.colors.inkMuted),
          child: widget.child,
        ),
      ),
    );
  }
}
