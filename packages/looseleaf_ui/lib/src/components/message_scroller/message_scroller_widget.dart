import 'package:flutter/widgets.dart';

/// The frame of a chat transcript: a [MessageScrollerViewport] filling it,
/// with [MessageScrollerButton]s floating over its edges.
///
/// Mirrors `MessageScroller` in upstream
/// `src/components/ui/message-scroller.tsx`.
class MessageScroller extends StatelessWidget {
  const MessageScroller({super.key, required this.children});

  /// The viewport first, then the buttons.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Stack(fit: StackFit.expand, children: children);
}
