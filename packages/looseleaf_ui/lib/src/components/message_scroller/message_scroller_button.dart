import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_provider.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_types.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The jump button floating over a [MessageScroller]'s edge: centered
/// 16 px from the bottom ([MessageScrollerDirection.end]) or the top. It
/// slides in while there is somewhere to jump, and is neither focusable
/// nor clickable otherwise. Pressing it glides to that end and hands the
/// keyboard to the transcript.
///
/// Mirrors `MessageScrollerButton` in upstream
/// `src/components/ui/message-scroller.tsx`.
class MessageScrollerButton extends StatelessWidget {
  const MessageScrollerButton({
    super.key,
    this.direction = MessageScrollerDirection.end,
    this.variant = ButtonVariant.secondary,
    this.size = ButtonSize.iconSm,
    this.animate = true,
    this.child,
    this.semanticLabel,
  });

  final MessageScrollerDirection direction;
  final ButtonVariant variant;
  final ButtonSize size;

  /// Whether the jump glides (upstream `behavior="smooth"`).
  final bool animate;

  /// The button's content; a down arrow (up for the start) by default.
  final Widget? child;

  /// The accessible name; "Scroll to end" or "Scroll to start".
  final String? semanticLabel;

  static const double _inset = Spacing.d16;
  static const double _hiddenScale = 0.95;

  @override
  Widget build(BuildContext context) {
    final controller = MessageScrollerProvider.of(context);
    final toEnd = direction == MessageScrollerDirection.end;
    final duration = InkMotion.of(context, InkMotion.sheet);
    void jump() {
      controller.viewportFocusNode?.requestFocus();
      switch (direction) {
        case MessageScrollerDirection.start:
          controller.scrollToStart(animate: animate);
        case MessageScrollerDirection.end:
          controller.scrollToEnd(animate: animate);
      }
    }

    final button = Button(
      variant: variant,
      size: size,
      semanticLabel:
          semanticLabel ??
          switch (toEnd) {
            true => 'Scroll to end',
            false => 'Scroll to start',
          },
      onPressed: jump,
      child:
          child ??
          Transform.rotate(
            angle: switch (toEnd) {
              true => 0,
              false => math.pi,
            },
            child: const InkIcon('arrow-down'),
          ),
    );
    return Positioned(
      left: 0,
      right: 0,
      bottom: switch (toEnd) {
        true => _inset,
        false => null,
      },
      top: switch (toEnd) {
        true => null,
        false => _inset,
      },
      child: Center(
        child: ValueListenableBuilder<MessageScrollerScrollable>(
          valueListenable: controller.scrollable,
          builder: (context, scrollable, child) {
            final active = scrollable.toward(direction);
            return IgnorePointer(
              ignoring: !active,
              child: ExcludeFocus(
                excluding: !active,
                child: ExcludeSemantics(
                  excluding: !active,
                  child: AnimatedSlide(
                    offset: switch ((active, toEnd)) {
                      (true, _) => Offset.zero,
                      (false, true) => const Offset(0, 1),
                      (false, false) => const Offset(0, -1),
                    },
                    duration: duration,
                    curve: InkMotion.settle,
                    child: AnimatedScale(
                      scale: switch (active) {
                        true => 1,
                        false => _hiddenScale,
                      },
                      duration: duration,
                      curve: InkMotion.settle,
                      child: AnimatedOpacity(
                        opacity: switch (active) {
                          true => 1,
                          false => 0,
                        },
                        duration: duration,
                        curve: InkMotion.settle,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: button,
        ),
      ),
    );
  }
}
