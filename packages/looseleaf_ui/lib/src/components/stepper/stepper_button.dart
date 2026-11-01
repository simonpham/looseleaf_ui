import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/stepper/stepper_metrics.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A [Stepper]'s − or + cell: a highlighter swipe on hover, a highlighter
/// fill while held, graphite when nothing is left in its direction.
///
/// It is not a Tab stop (the number takes the keyboard), but it is a real
/// button for screen readers. Pressing it calls [onHold]; releasing,
/// cancelling or leaving calls [onRelease]. A screen reader's activate
/// calls [onStep] once.
///
/// Mirrors `StepperButton` in upstream `src/components/ui/stepper.tsx`.
class StepperButton extends StatefulWidget {
  const StepperButton({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.onHold,
    this.onRelease,
    this.onStep,
    this.onBlocked,
    this.exhausted = false,
    this.disabled = false,
    this.holding = false,
  });

  /// The icon.
  final Widget child;

  /// The button's name, like "Increase".
  final String semanticLabel;

  /// Called when a pointer goes down on it.
  final VoidCallback? onHold;

  /// Called when that pointer lifts or is cancelled.
  final VoidCallback? onRelease;

  /// Called on a screen reader's activate.
  final VoidCallback? onStep;

  /// Called when it is pressed with nothing left (upstream's rattle).
  final VoidCallback? onBlocked;

  /// Nothing left in its direction: graphite, `aria-disabled`.
  final bool exhausted;

  /// The whole stepper is disabled.
  final bool disabled;

  /// Held down: the highlighter fill (`data-holding`).
  final bool holding;

  @override
  State<StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<StepperButton> {
  bool _hovered = false;
  bool _down = false;

  void _onDown(PointerDownEvent event) {
    if (widget.disabled) return;
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    if (widget.exhausted) {
      widget.onBlocked?.call();
      return;
    }
    setState(() => _down = true);
    widget.onHold?.call();
  }

  void _onUp() {
    if (!_down) return;
    setState(() => _down = false);
    widget.onRelease?.call();
  }

  @override
  void dispose() {
    if (_down) scheduleMicrotask(() => widget.onRelease?.call());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final off = widget.disabled || widget.exhausted;
    final fill = switch ((off, widget.holding || _down, _hovered)) {
      (true, _, _) => null,
      (false, true, _) => theme.colors.hi.withValues(alpha: 0.85),
      (false, false, true) => theme.colors.hiSelect,
      _ => null,
    };
    return Semantics(
      button: true,
      enabled: !off,
      label: widget.semanticLabel,
      onTap: switch (off) {
        true => null,
        false => widget.onStep,
      },
      child: MouseRegion(
        cursor: switch (widget.disabled) {
          true => SystemMouseCursors.forbidden,
          false => SystemMouseCursors.basic,
        },
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) {
          setState(() => _hovered = false);
          _onUp();
        },
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onDown,
          onPointerUp: (_) => _onUp(),
          onPointerCancel: (_) => _onUp(),
          child: ExcludeSemantics(
            child: AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: StepperMetrics.swipeRadius,
                ),
                child: Center(
                  child: IconTheme.merge(
                    data: IconThemeData(
                      size: StepperMetrics.icon,
                      color: switch (off) {
                        true => theme.colors.pencilText,
                        false => theme.colors.ink,
                      },
                    ),
                    child: InkContent(
                      style: TextStyle(
                        color: switch (off) {
                          true => theme.colors.pencilText,
                          false => theme.colors.ink,
                        },
                      ),
                      iconSize: StepperMetrics.icon,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
