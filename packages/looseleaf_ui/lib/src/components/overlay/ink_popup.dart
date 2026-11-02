import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds a popup's content; [position] is where it landed (null until the
/// first layout, and for centred popups).
typedef InkPopupBuilder =
    Widget Function(
      BuildContext context,
      OverlayPosition? position,
    );

/// A popup anchored to [child] (or centred, for dialogs), shown while
/// [open]: the whole overlay behaviour in one widget.
///
/// - **Placement**: [side], [align], [sideOffset], [alignOffset],
///   [collisionPadding], [avoidCollisions], [anchor] (see
///   [AnchoredOverlay]); [centered] puts it in the window where
///   [placement] says (the middle, 16 px from the edges, by default),
///   scrolling when tall.
/// - **Motion**: [motion] in and out ([PopupMotion]); it stays shown until
///   its exit ends. Reduced motion skips it.
/// - **Dismissal**: Escape ([dismissOnEscape]), a pointer down outside it
///   and its [groupId] ([dismissOnOutsideTap]), focus leaving it
///   ([dismissOnFocusOutside]) call [onOpenChange] with false, after
///   [onDismiss] hears why.
/// - **Focus**: [autofocus] moves focus inside on open, [modal] traps Tab
///   inside, and focus goes back to where it was on close ([restoreFocus]),
///   except after an outside tap.
/// - **Barrier**: [modal] puts a barrier under it that blocks the app;
///   [scrim] dims it with Looseleaf's vignette ([OverlayScrim]). Tapping
///   the barrier dismisses when [dismissOnOutsideTap].
///
/// Popover and Tooltip are built on it; dialogs, sheets, menus, selects and
/// hover cards should be too.
class InkPopup extends StatefulWidget {
  const InkPopup({
    super.key,
    required this.open,
    required this.popupBuilder,
    required this.child,
    this.onOpenChange,
    this.onDismiss,
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.center,
    this.sideOffset = 0,
    this.alignOffset = 0,
    this.collisionPadding = Spacing.d8,
    this.avoidCollisions = true,
    this.anchor,
    this.centered = false,
    this.placement = PopupPlacement.center,
    this.motion = PopupMotionStyle.pop,
    this.modal = false,
    this.scrim = false,
    this.autofocus = true,
    this.restoreFocus = true,
    this.dismissOnEscape = true,
    this.dismissOnOutsideTap = true,
    this.dismissOnFocusOutside = false,
    this.groupId,
    this.barrierLabel,
  });

  /// Whether the popup is shown.
  final bool open;

  /// Builds the popup.
  final InkPopupBuilder popupBuilder;

  /// The anchor (usually the trigger).
  final Widget child;

  /// Asked to change [open]; dismissals ask for false.
  final ValueChanged<bool>? onOpenChange;

  /// Hears why a dismissal happened, before [onOpenChange].
  final ValueChanged<OverlayDismissReason>? onDismiss;

  /// The preferred side.
  final OverlaySide side;

  /// The alignment along the side.
  final OverlayAlign align;

  /// The gap to the anchor.
  final double sideOffset;

  /// A shift along the side.
  final double alignOffset;

  /// How far it keeps from the overlay's edges.
  final double collisionPadding;

  /// Flip and slide to stay inside.
  final bool avoidCollisions;

  /// A rect in [child]'s coordinates to anchor to.
  final Rect? anchor;

  /// Centred in the overlay instead of anchored.
  final bool centered;

  /// Where a [centered] popup sits.
  final PopupPlacement placement;

  /// How it comes and goes.
  final PopupMotionStyle motion;

  /// Blocks the app below and traps focus.
  final bool modal;

  /// Dims the app below (implies a barrier).
  final bool scrim;

  /// Moves focus inside on open.
  final bool autofocus;

  /// Gives focus back on close.
  final bool restoreFocus;

  /// Escape dismisses.
  final bool dismissOnEscape;

  /// A pointer down outside (or a barrier tap) dismisses.
  final bool dismissOnOutsideTap;

  /// Focus moving out dismisses.
  final bool dismissOnFocusOutside;

  /// The tap region group shared with the trigger; the popup's own when
  /// null (wrap the trigger in a `TapRegion` of [groupId] so tapping it
  /// does not count as outside).
  final Object? groupId;

  /// What a dismissing barrier says to screen readers.
  final String? barrierLabel;

  @override
  State<InkPopup> createState() => _InkPopupState();
}

class _InkPopupState extends State<InkPopup>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  late final AnimationController _motion;
  bool _restore = true;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this);
    _restore = widget.restoreFocus;
    if (widget.open) _show(animate: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _durations();
  }

  @override
  void didUpdateWidget(InkPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    _durations();
    if (widget.open == oldWidget.open) return;
    switch (widget.open) {
      case true:
        _restore = widget.restoreFocus;
        _show(animate: true);
      case false:
        unawaited(_hide());
    }
  }

  void _durations() {
    _motion
      ..duration = InkMotion.of(context, widget.motion.enter)
      ..reverseDuration = InkMotion.of(context, widget.motion.exit);
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
    if (!widget.open || _dismissed) return;
    _dismissed = true;
    scheduleMicrotask(() => _dismissed = false);
    if (reason == OverlayDismissReason.outside) _restore = false;
    widget.onDismiss?.call(reason);
    widget.onOpenChange?.call(false);
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  Widget _content(BuildContext context, OverlayPosition? position) {
    final open = widget.open;
    return IgnorePointer(
      ignoring: !open,
      child: OverlayDismiss(
        groupId: widget.groupId,
        escape: widget.dismissOnEscape && open,
        outside: widget.dismissOnOutsideTap && open && !_barrier,
        onDismiss: _dismiss,
        child: OverlayFocus(
          autofocus: widget.autofocus,
          trapped: widget.modal,
          restoreFocus: _restore,
          onFocusOutside: switch (widget.dismissOnFocusOutside) {
            true => () => _dismiss(OverlayDismissReason.focusOutside),
            false => null,
          },
          child: PopupMotion(
            animation: _motion,
            style: widget.motion,
            side: switch (widget.centered) {
              true => null,
              false => position?.side ?? widget.side,
            },
            align: widget.align,
            child: widget.popupBuilder(context, position),
          ),
        ),
      ),
    );
  }

  bool get _barrier => widget.modal || widget.scrim;

  Widget? _barrierWidget() {
    if (!_barrier) return null;
    return OverlayScrim(
      opacity: _motion,
      dim: widget.scrim,
      semanticLabel: widget.barrierLabel,
      onDismiss: switch (widget.dismissOnOutsideTap) {
        true => () => _dismiss(OverlayDismissReason.outside),
        false => null,
      },
    );
  }

  /// `mt-[12dvh]`.
  static const double _topShare = 0.12;

  Widget _placed(BuildContext context) {
    final content = _content(context, null);
    final height = MediaQuery.sizeOf(context).height;
    return switch (widget.placement) {
      PopupPlacement.center => SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.d16),
            child: content,
          ),
        ),
      ),
      PopupPlacement.top => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Spacing.d16,
              Spacing.d16 + height * _topShare,
              Spacing.d16,
              Spacing.d16,
            ),
            child: content,
          ),
        ),
      ),
      PopupPlacement.phoneBottom => SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(child: content),
        ),
      ),
      PopupPlacement.phoneTop => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: Spacing.d8),
            child: content,
          ),
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.centered) {
      return OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => Stack(
          fit: StackFit.expand,
          children: [
            ?_barrierWidget(),
            _placed(context),
          ],
        ),
        child: widget.child,
      );
    }
    return AnchoredOverlay(
      controller: _portal,
      side: widget.side,
      align: widget.align,
      sideOffset: widget.sideOffset,
      alignOffset: widget.alignOffset,
      collisionPadding: widget.collisionPadding,
      avoidCollisions: widget.avoidCollisions,
      anchor: widget.anchor,
      barrier: _barrierWidget(),
      overlayBuilder: (context, position) => ValueListenableBuilder(
        valueListenable: position,
        builder: (context, placed, _) => _content(context, placed),
      ),
      child: widget.child,
    );
  }
}
