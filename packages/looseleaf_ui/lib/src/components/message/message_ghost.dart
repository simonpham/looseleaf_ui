import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message/message_scope.dart';

/// Tells the enclosing [Message] that [child] is a ghost bubble (bare words,
/// no drawn body), so its [MessageHeader] and [MessageFooter] drop their
/// 12 px inset. A ghost [Bubble] wraps itself in one.
///
/// Mirrors upstream's `group-has-data-[variant=ghost]/message:px-0` in
/// `src/components/ui/message.tsx`.
class MessageGhost extends StatefulWidget {
  const MessageGhost({super.key, required this.child});

  final Widget child;

  @override
  State<MessageGhost> createState() => _MessageGhostState();
}

class _MessageGhostState extends State<MessageGhost> {
  ValueChanged<int>? _counted;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final count = MessageScope.maybeOf(context)?.countGhost;
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
  Widget build(BuildContext context) => widget.child;
}
