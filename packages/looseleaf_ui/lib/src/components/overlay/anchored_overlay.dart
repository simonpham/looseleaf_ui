import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';

/// Builds a popup that knows where it landed; [position] updates after each
/// layout (the side after a flip, the anchor's centre for an arrow).
typedef AnchoredOverlayBuilder = Widget Function(
  BuildContext context,
  ValueListenable<OverlayPosition?> position,
);

/// Shows a popup in the nearest [Overlay], anchored to [child] (the trigger)
/// while [controller] says so: on [side] of it, aligned by [align],
/// [sideOffset] away, flipping and sliding to stay [collisionPadding] inside
/// the overlay. The popup gets loose constraints of the overlay minus the
/// padding, so it sizes itself.
///
/// [anchor] anchors to a rect in [child]'s own coordinates instead of its
/// whole box (a context menu's pointer); [barrier] goes under the popup,
/// filling the overlay (a scrim, a click-catcher).
///
/// The foundation of popovers, tooltips, hover cards, menus and selects;
/// Radix's `Popper` in upstream's primitives, built on
/// [OverlayPortal.overlayChildLayoutBuilder].
class AnchoredOverlay extends StatefulWidget {
  const AnchoredOverlay({
    super.key,
    required this.controller,
    required this.overlayBuilder,
    required this.child,
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.center,
    this.sideOffset = 0,
    this.alignOffset = 0,
    this.collisionPadding = 0,
    this.avoidCollisions = true,
    this.anchor,
    this.barrier,
  });

  /// Shows and hides the popup.
  final OverlayPortalController controller;

  /// Builds the popup.
  final AnchoredOverlayBuilder overlayBuilder;

  /// The anchor (usually the trigger).
  final Widget child;

  /// The preferred side.
  final OverlaySide side;

  /// The alignment along the side.
  final OverlayAlign align;

  /// The gap between anchor and popup.
  final double sideOffset;

  /// A shift along the side.
  final double alignOffset;

  /// How far the popup keeps from the overlay's edges.
  final double collisionPadding;

  /// Flip and slide to stay inside the overlay.
  final bool avoidCollisions;

  /// A rect in [child]'s coordinates to anchor to; [child]'s box when null.
  final Rect? anchor;

  /// Fills the overlay under the popup.
  final Widget? barrier;

  @override
  State<AnchoredOverlay> createState() => _AnchoredOverlayState();
}

class _AnchoredOverlayState extends State<AnchoredOverlay> {
  final ValueNotifier<OverlayPosition?> _position = ValueNotifier(null);
  OverlayPosition? _pending;

  void _report(OverlayPosition position) {
    if (position == _position.value || position == _pending) return;
    final first = _pending == null;
    _pending = position;
    if (!first) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final next = _pending;
      _pending = null;
      if (!mounted || next == null) return;
      _position.value = next;
    });
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: widget.controller,
      overlayChildBuilder: (context, info) {
        final local = widget.anchor ?? Offset.zero & info.childSize;
        final anchor = MatrixUtils.transformRect(
          info.childPaintTransform,
          local,
        );
        final popup = CustomSingleChildLayout(
          delegate: _AnchorDelegate(
            anchor: anchor,
            side: widget.side,
            align: widget.align,
            sideOffset: widget.sideOffset,
            alignOffset: widget.alignOffset,
            padding: widget.collisionPadding,
            avoidCollisions: widget.avoidCollisions,
            textDirection: direction,
            onPosition: _report,
          ),
          child: widget.overlayBuilder(context, _position),
        );
        final barrier = widget.barrier;
        if (barrier == null) return popup;
        return Stack(
          fit: StackFit.expand,
          children: [barrier, popup],
        );
      },
      child: widget.child,
    );
  }
}

class _AnchorDelegate extends SingleChildLayoutDelegate {
  _AnchorDelegate({
    required this.anchor,
    required this.side,
    required this.align,
    required this.sideOffset,
    required this.alignOffset,
    required this.padding,
    required this.avoidCollisions,
    required this.textDirection,
    required this.onPosition,
  });

  final Rect anchor;
  final OverlaySide side;
  final OverlayAlign align;
  final double sideOffset;
  final double alignOffset;
  final double padding;
  final bool avoidCollisions;
  final TextDirection textDirection;
  final ValueChanged<OverlayPosition> onPosition;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(constraints.biggest)
          .deflate(EdgeInsets.all(padding));

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final position = OverlayPosition.resolve(
      anchor: anchor,
      content: childSize,
      bounds: size,
      side: side,
      align: align,
      sideOffset: sideOffset,
      alignOffset: alignOffset,
      collisionPadding: padding,
      avoidCollisions: avoidCollisions,
      textDirection: textDirection,
    );
    onPosition(position);
    return position.offset;
  }

  @override
  bool shouldRelayout(_AnchorDelegate oldDelegate) =>
      oldDelegate.anchor != anchor ||
      oldDelegate.side != side ||
      oldDelegate.align != align ||
      oldDelegate.sideOffset != sideOffset ||
      oldDelegate.alignOffset != alignOffset ||
      oldDelegate.padding != padding ||
      oldDelegate.avoidCollisions != avoidCollisions ||
      oldDelegate.textDirection != textDirection;
}
