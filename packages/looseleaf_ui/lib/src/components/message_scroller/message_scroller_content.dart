import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_controller.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_provider.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The transcript inside a [MessageScrollerViewport]: messages stacked
/// 20 px apart with 16 px around them, at least as tall as the viewport,
/// and after them the spacer that lets a new reply reach the top.
///
/// Mirrors `MessageScrollerContent` in upstream
/// `src/components/ui/message-scroller.tsx`.
class MessageScrollerContent extends StatefulWidget {
  const MessageScrollerContent({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(Spacing.d16),
    this.gap = Spacing.d20,
  });

  /// [MessageScrollerItem]s and anything between them (separators).
  final List<Widget> children;

  final EdgeInsets padding;
  final double gap;

  @override
  State<MessageScrollerContent> createState() => _MessageScrollerContentState();
}

class _MessageScrollerContentState extends State<MessageScrollerContent> {
  MessageScrollerController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = MessageScrollerProvider.of(context);
    if (controller == _controller) return;
    _controller?.detachContent(context);
    _controller = controller..attachContent(context);
  }

  @override
  void dispose() {
    _controller?.detachContent(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MessageScrollerProvider.of(context);
    controller.contentEndPadding = widget.padding.bottom;
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: widget.gap,
            children: widget.children,
          ),
          ValueListenableBuilder<double>(
            valueListenable: controller.spacer,
            builder: (context, height, _) => SizedBox(height: height),
          ),
        ],
      ),
    );
  }
}
