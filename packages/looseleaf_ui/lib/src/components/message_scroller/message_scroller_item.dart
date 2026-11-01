import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_controller.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_provider.dart';

/// One message in a [MessageScrollerContent]. [messageId] lets
/// `scrollToMessage` and the visibility report find it; a [scrollAnchor]
/// (the start of a reply) is brought to the top when it arrives, with a
/// peek of the message before it.
///
/// Mirrors `MessageScrollerItem` in upstream
/// `src/components/ui/message-scroller.tsx`.
class MessageScrollerItem extends StatefulWidget {
  const MessageScrollerItem({
    super.key,
    required this.child,
    this.messageId,
    this.scrollAnchor = false,
  });

  final Widget child;
  final String? messageId;

  /// Brings this message to the top when it arrives.
  final bool scrollAnchor;

  @override
  State<MessageScrollerItem> createState() => _MessageScrollerItemState();
}

class _MessageScrollerItemState extends State<MessageScrollerItem> {
  MessageScrollerController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = MessageScrollerProvider.of(context);
    if (controller == _controller) return;
    _controller?.detachItem(this);
    _controller = controller;
    controller.attachItem(
      this,
      context,
      id: widget.messageId,
      anchor: widget.scrollAnchor,
    );
  }

  @override
  void didUpdateWidget(MessageScrollerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messageId == widget.messageId &&
        oldWidget.scrollAnchor == widget.scrollAnchor) {
      return;
    }
    _controller?.updateItem(
      this,
      id: widget.messageId,
      anchor: widget.scrollAnchor,
    );
  }

  @override
  void dispose() {
    _controller?.detachItem(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
