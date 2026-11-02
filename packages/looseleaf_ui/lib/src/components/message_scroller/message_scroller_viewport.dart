import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_provider.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_types.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The scrolling window of a chat transcript: a named region and a tab
/// stop, so the arrows, Page keys, Home, End and Space scroll it. The page
/// fades at an edge while there is more to scroll there (20 px at the top,
/// 28 px at the bottom).
///
/// Wheel, drag and key scrolls toward the start take over from following
/// at once; scrolling toward the end while following changes nothing.
///
/// Mirrors `MessageScrollerViewport` in upstream
/// `src/components/ui/message-scroller.tsx`.
class MessageScrollerViewport extends StatefulWidget {
  const MessageScrollerViewport({
    super.key,
    required this.child,
    this.semanticLabel = 'Messages',
    this.preserveScrollOnPrepend = true,
    this.focusNode,
  });

  /// Usually a [MessageScrollerContent].
  final Widget child;

  /// The region's name.
  final String semanticLabel;

  /// Keeps the message you read in place when older ones are prepended.
  final bool preserveScrollOnPrepend;

  final FocusNode? focusNode;

  @override
  State<MessageScrollerViewport> createState() =>
      _MessageScrollerViewportState();
}

class _MessageScrollerViewportState extends State<MessageScrollerViewport> {
  static const double _fadeTop = Spacing.d20;
  static const double _fadeBottom = Spacing.d28;
  static const double _line = Spacing.d40;
  static const double _page = 0.8;

  FocusNode? _own;
  bool _focusVisible = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_own ??= FocusNode(debugLabel: 'Messages'));

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  void _later(VoidCallback run) {
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      run();
      return;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) run();
    });
  }

  bool _onScroll(ScrollNotification notification) {
    final controller = MessageScrollerProvider.of(context);
    if (notification case ScrollUpdateNotification(
      dragDetails: DragUpdateDetails(),
      :final scrollDelta?,
    ) when scrollDelta != 0) {
      controller.userIntent(switch (scrollDelta < 0) {
        true => MessageScrollerDirection.start,
        false => MessageScrollerDirection.end,
      });
    }
    if (notification is ScrollUpdateNotification) {
      _later(controller.handleScroll);
    }
    return false;
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    final controller = MessageScrollerProvider.of(context);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.handleResize();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
    return false;
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || event.scrollDelta.dy == 0) return;
    MessageScrollerProvider.of(context).userIntent(
      switch (event.scrollDelta.dy < 0) {
        true => MessageScrollerDirection.start,
        false => MessageScrollerDirection.end,
      },
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final controller = MessageScrollerProvider.of(context);
    final scroll = controller.scrollController;
    if (!scroll.hasClients) return KeyEventResult.ignored;
    final position = scroll.position;
    final page = position.viewportDimension * _page;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.home) {
      controller
        ..userIntent(MessageScrollerDirection.start)
        ..scrollToStart();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      controller
        ..userIntent(MessageScrollerDirection.end)
        ..scrollToEnd();
      return KeyEventResult.handled;
    }
    final delta = switch (key) {
      LogicalKeyboardKey.arrowUp => -_line,
      LogicalKeyboardKey.arrowDown => _line,
      LogicalKeyboardKey.pageUp => -page,
      LogicalKeyboardKey.pageDown => page,
      LogicalKeyboardKey.space when shift => -page,
      LogicalKeyboardKey.space => page,
      _ => 0.0,
    };
    if (delta == 0) return KeyEventResult.ignored;
    controller.userIntent(switch (delta < 0) {
      true => MessageScrollerDirection.start,
      false => MessageScrollerDirection.end,
    });
    position.jumpTo(
      (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
    return KeyEventResult.handled;
  }

  void _onFocusChange(bool focused) {
    final visible =
        focused &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    if (visible == _focusVisible) return;
    setState(() => _focusVisible = visible);
  }

  /// Always a [ShaderMask], so the scroll view below keeps its state when
  /// the fades come and go.
  Widget _fade(MessageScrollerScrollable scrollable, Widget child) {
    final top = switch (scrollable.start) {
      true => _fadeTop,
      false => 0.0,
    };
    final bottom = switch (scrollable.end) {
      true => _fadeBottom,
      false => 0.0,
    };
    const shown = Color(0xFF000000);
    const hidden = Color(0x00000000);
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        final height = bounds.height;
        if (height <= 0 || (top == 0 && bottom == 0)) {
          return const LinearGradient(colors: [shown, shown]).createShader(
            bounds,
          );
        }
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [hidden, shown, shown, hidden],
          stops: [
            0,
            (top / height).clamp(0.0, 0.5),
            (1 - bottom / height).clamp(0.5, 1.0),
            1,
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = MessageScrollerProvider.of(context);
    final theme = LooseleafTheme.of(context);
    controller
      ..reducedMotion = InkMotion.reducedIn(context)
      ..preserveScrollOnPrepend = widget.preserveScrollOnPrepend
      ..viewportFocusNode = _focusNode;
    final view = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: controller.scrollController,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: widget.child,
        ),
      ),
    );
    final region = Semantics(
      container: true,
      label: widget.semanticLabel,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        onFocusChange: _onFocusChange,
        child: Listener(
          onPointerSignal: _onPointerSignal,
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: _onMetrics,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: ValueListenableBuilder<MessageScrollerScrollable>(
                valueListenable: controller.scrollable,
                builder: (context, scrollable, child) =>
                    _fade(scrollable, view),
              ),
            ),
          ),
        ),
      ),
    );
    return Stack(
      fit: StackFit.passthrough,
      children: [
        region,
        if (_focusVisible)
          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.d4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colors.focus,
                      width: Spacing.d2,
                    ),
                    borderRadius: BorderRadius.circular(Spacing.d4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
