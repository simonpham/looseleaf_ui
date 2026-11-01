import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_controller.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_types.dart';

/// Gives a chat transcript's parts (and your toolbar beside it) one
/// [MessageScrollerController]: [controller] when given, else one made
/// here from the options and disposed with it.
///
/// Read it with [MessageScrollerProvider.of] to jump (`scrollToEnd`,
/// `scrollToMessage`) or to listen to `scrollable` and `visibility`
/// (upstream's `useMessageScroller`, `useMessageScrollerScrollable` and
/// `useMessageScrollerVisibility`).
///
/// ```dart
/// MessageScrollerProvider(
///   autoScroll: true,
///   child: MessageScroller(children: [
///     MessageScrollerViewport(
///       child: MessageScrollerContent(children: [
///         for (final m in messages)
///           MessageScrollerItem(messageId: m.id, child: Text(m.text)),
///       ]),
///     ),
///     const MessageScrollerButton(),
///   ]),
/// )
/// ```
///
/// Mirrors `MessageScrollerProvider` in upstream
/// `src/components/ui/message-scroller.tsx`.
class MessageScrollerProvider extends StatefulWidget {
  const MessageScrollerProvider({
    super.key,
    required this.child,
    this.controller,
    this.autoScroll = false,
    this.defaultPosition = MessageScrollerPosition.end,
    this.edgeThreshold = 8,
    this.previousItemPeek = 64,
    this.scrollMargin = 0,
  });

  final Widget child;

  /// A controller you own; the options below are applied to it.
  final MessageScrollerController? controller;

  /// Follows new messages while you are at the end.
  final bool autoScroll;

  /// Where the transcript opens.
  final MessageScrollerPosition defaultPosition;

  /// How close to an end counts as at it, in px.
  final double edgeThreshold;

  /// How much of the previous message stays above a new reply.
  final double previousItemPeek;

  /// Room kept above a message scrolled to.
  final double scrollMargin;

  /// The nearest controller.
  static MessageScrollerController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_MessageScrollerScope>();
    if (scope == null) {
      throw FlutterError(
        'MessageScroller parts must be used inside a MessageScrollerProvider.',
      );
    }
    return scope.controller;
  }

  @override
  State<MessageScrollerProvider> createState() =>
      _MessageScrollerProviderState();
}

class _MessageScrollerProviderState extends State<MessageScrollerProvider> {
  MessageScrollerController? _own;

  MessageScrollerController get _controller =>
      widget.controller ??
      (_own ??= MessageScrollerController(autoScroll: widget.autoScroll));

  void _apply() {
    _controller
      ..defaultPosition = widget.defaultPosition
      ..edgeThreshold = widget.edgeThreshold
      ..previousItemPeek = widget.previousItemPeek
      ..scrollMargin = widget.scrollMargin
      ..autoScroll = widget.autoScroll;
  }

  @override
  void initState() {
    super.initState();
    _apply();
  }

  @override
  void didUpdateWidget(MessageScrollerProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _apply();
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _MessageScrollerScope(controller: _controller, child: widget.child);
}

class _MessageScrollerScope extends InheritedWidget {
  const _MessageScrollerScope({required this.controller, required super.child});

  final MessageScrollerController controller;

  @override
  bool updateShouldNotify(_MessageScrollerScope oldWidget) =>
      oldWidget.controller != controller;
}
