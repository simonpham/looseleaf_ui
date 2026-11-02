import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A popup pinned to one [side] of the window that slides in from it while
/// [open]: the edge-anchored counterpart of [InkPopup], for sheets and
/// drawers.
///
/// It fills the window along the side (full height for left and right,
/// full width for top and bottom) and sizes itself across it. [modal] dims
/// the app with Looseleaf's vignette, blocks it and traps Tab; a tap on the
/// dim, Escape, or (when not modal) a pointer down outside it and its
/// [groupId] closes it through [onOpenChange]. Focus moves inside on open
/// and goes back on close.
///
/// [dragToDismiss] lets a drag towards the [side] pull it out, like vaul's
/// drawer: let go past a quarter of its size, or with a flick, and it
/// closes; otherwise it springs back.
class EdgePopup extends StatefulWidget {
  const EdgePopup({
    super.key,
    required this.open,
    required this.side,
    required this.popupBuilder,
    required this.child,
    this.onOpenChange,
    this.modal = true,
    this.dismissOnOutsideTap = true,
    this.dragToDismiss = false,
    this.groupId,
    this.barrierLabel,
  });

  /// Whether it is shown.
  final bool open;

  /// The window edge it hangs from.
  final OverlaySide side;

  /// Builds the popup.
  final WidgetBuilder popupBuilder;

  /// What stays in place (usually the trigger).
  final Widget child;

  /// Asked to change [open]; dismissals ask for false.
  final ValueChanged<bool>? onOpenChange;

  /// Dims and blocks the app and traps focus.
  final bool modal;

  /// A tap on the dim (or outside, when not modal) closes it.
  final bool dismissOnOutsideTap;

  /// A drag towards [side] closes it.
  final bool dragToDismiss;

  /// The tap region group shared with the trigger.
  final Object? groupId;

  /// What the dim says to screen readers.
  final String? barrierLabel;

  @override
  State<EdgePopup> createState() => _EdgePopupState();
}

class _EdgePopupState extends State<EdgePopup>
    with SingleTickerProviderStateMixin {
  static const double _dismissShare = 0.25;
  static const double _flick = 500;

  final OverlayPortalController _portal = OverlayPortalController();
  late final AnimationController _motion;
  late final CurvedAnimation _curve;
  final GlobalKey _sheet = GlobalKey();
  bool _restore = true;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this);
    _curve = CurvedAnimation(parent: _motion, curve: InkMotion.easeOut);
    if (widget.open) _show(animate: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion
      ..duration = InkMotion.of(context, InkMotion.sheet)
      ..reverseDuration = InkMotion.of(context, InkMotion.sheet);
  }

  @override
  void didUpdateWidget(EdgePopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open == oldWidget.open) return;
    switch (widget.open) {
      case true:
        _restore = true;
        _show(animate: true);
      case false:
        unawaited(_hide());
    }
  }

  void _show({required bool animate}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.open) return;
      _portal.show();
      if (!animate) {
        _motion.value = 1;
        return;
      }
      unawaited(_motion.forward());
    });
  }

  Future<void> _hide() async {
    await _motion.reverse().orCancel.catchError((_) {});
    if (!mounted || widget.open) return;
    _portal.hide();
    setState(() {});
  }

  void _dismiss(OverlayDismissReason reason) {
    if (!widget.open) return;
    if (reason == OverlayDismissReason.outside) _restore = false;
    widget.onOpenChange?.call(false);
  }

  double get _extent {
    final size = _sheet.currentContext?.size;
    if (size == null) return 1;
    return switch (widget.side.vertical) {
      true => size.height,
      false => size.width,
    };
  }

  double _towardSide(Offset delta) => switch (widget.side) {
    OverlaySide.bottom => delta.dy,
    OverlaySide.top => -delta.dy,
    OverlaySide.right => delta.dx,
    OverlaySide.left => -delta.dx,
  };

  void _dragUpdate(DragUpdateDetails details) {
    _dragging = true;
    _motion.value -= _towardSide(details.delta) / _extent;
  }

  void _dragEnd(DragEndDetails details) {
    _dragging = false;
    final speed = _towardSide(details.velocity.pixelsPerSecond);
    if (speed > _flick || _motion.value < 1 - _dismissShare) {
      _dismiss(OverlayDismissReason.escape);
      return;
    }
    unawaited(_motion.forward());
  }

  @override
  void dispose() {
    _curve.dispose();
    _motion.dispose();
    super.dispose();
  }

  Offset _hidden() => switch (widget.side) {
    OverlaySide.bottom => const Offset(0, 1),
    OverlaySide.top => const Offset(0, -1),
    OverlaySide.right => const Offset(1, 0),
    OverlaySide.left => const Offset(-1, 0),
  };

  Widget _popup(BuildContext context) {
    final open = widget.open;
    Widget sheet = KeyedSubtree(
      key: _sheet,
      child: widget.popupBuilder(context),
    );
    if (widget.dragToDismiss) {
      sheet = switch (widget.side.vertical) {
        true => GestureDetector(
          onVerticalDragUpdate: _dragUpdate,
          onVerticalDragEnd: _dragEnd,
          child: sheet,
        ),
        false => GestureDetector(
          onHorizontalDragUpdate: _dragUpdate,
          onHorizontalDragEnd: _dragEnd,
          child: sheet,
        ),
      };
    }
    final hidden = _hidden();
    final slid = AnimatedBuilder(
      animation: _motion,
      child: sheet,
      builder: (context, child) {
        final shown = switch (_dragging) {
          true => _motion.value,
          false => _curve.value,
        };
        return FractionalTranslation(
          translation: hidden * (1 - shown),
          child: child,
        );
      },
    );
    final content = IgnorePointer(
      ignoring: !open,
      child: OverlayDismiss(
        groupId: widget.groupId,
        escape: open,
        outside: widget.dismissOnOutsideTap && open && !widget.modal,
        onDismiss: _dismiss,
        child: OverlayFocus(
          trapped: widget.modal,
          restoreFocus: _restore,
          child: slid,
        ),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.modal)
          OverlayScrim(
            opacity: _motion,
            semanticLabel: widget.barrierLabel,
            onDismiss: switch (widget.dismissOnOutsideTap) {
              true => () => _dismiss(OverlayDismissReason.outside),
              false => null,
            },
          ),
        switch (widget.side) {
          OverlaySide.right => Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: content,
          ),
          OverlaySide.left => Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: content,
          ),
          OverlaySide.top => Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: content,
          ),
          OverlaySide.bottom => Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: content,
          ),
        },
      ],
    );
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _portal,
    overlayChildBuilder: _popup,
    child: widget.child,
  );
}
