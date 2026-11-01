import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A run of [Message]s, stacked [gap] apart (`gap-2` upstream; examples
/// widen it).
///
/// Mirrors `MessageGroup` in upstream `src/components/ui/message.tsx`.
class MessageGroup extends StatelessWidget {
  const MessageGroup({
    super.key,
    required this.children,
    this.gap = Spacing.d8,
  });

  final List<Widget> children;

  /// The space between messages.
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: gap,
    children: children,
  );
}
