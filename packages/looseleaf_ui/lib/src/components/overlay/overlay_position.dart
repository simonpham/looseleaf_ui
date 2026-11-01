import 'dart:math' as math;
import 'dart:ui';

import 'package:looseleaf_ui/src/components/overlay/overlay.dart';

/// Where a popup lands: its top-left corner, the side it ended up on after
/// avoiding collisions, and where along its edge the anchor's centre falls
/// (for a pointer arrow).
final class OverlayPosition {
  const OverlayPosition({
    required this.offset,
    required this.side,
    required this.anchorCenter,
  });

  /// The popup's top-left corner in overlay coordinates.
  final Offset offset;

  /// The side it opened on: the requested one, or its opposite when the
  /// requested one had no room.
  final OverlaySide side;

  /// The anchor's centre along the popup's edge, from the popup's start
  /// (left for top/bottom, top for left/right), in popup pixels.
  final double anchorCenter;

  /// Places a [content]-sized popup on [side] of [anchor] inside [bounds],
  /// like Radix's popper (floating-ui `offset`, `flip`, `shift`):
  /// [sideOffset] away from the anchor, aligned by [align] and shifted by
  /// [alignOffset]; with [avoidCollisions] it flips to the opposite side
  /// when that has more room and slides along the side to stay
  /// [collisionPadding] inside [bounds].
  static OverlayPosition resolve({
    required Rect anchor,
    required Size content,
    required Size bounds,
    OverlaySide side = OverlaySide.bottom,
    OverlayAlign align = OverlayAlign.center,
    double sideOffset = 0,
    double alignOffset = 0,
    double collisionPadding = 0,
    bool avoidCollisions = true,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final placed = switch (avoidCollisions) {
      true => _flip(
        anchor,
        content,
        bounds,
        side,
        sideOffset,
        collisionPadding,
      ),
      false => side,
    };
    final main = _main(anchor, content, placed, sideOffset);
    final rtl = textDirection == TextDirection.rtl && placed.vertical;
    final along = switch ((align, rtl)) {
      (OverlayAlign.center, _) => OverlayAlign.center,
      (OverlayAlign.start, false) ||
      (OverlayAlign.end, true) => OverlayAlign.start,
      _ => OverlayAlign.end,
    };
    final (lo, hi, size, room) = switch (placed.vertical) {
      true => (anchor.left, anchor.right, content.width, bounds.width),
      false => (anchor.top, anchor.bottom, content.height, bounds.height),
    };
    var cross = switch (along) {
      OverlayAlign.start => lo + alignOffset,
      OverlayAlign.center => (lo + hi - size) / 2 + alignOffset,
      OverlayAlign.end => hi - size - alignOffset,
    };
    if (avoidCollisions) {
      final max = room - collisionPadding - size;
      cross = math.max(collisionPadding, math.min(cross, max));
    }
    final center = (lo + hi) / 2 - cross;
    return OverlayPosition(
      offset: switch (placed.vertical) {
        true => Offset(cross, main),
        false => Offset(main, cross),
      },
      side: placed,
      anchorCenter: center,
    );
  }

  static double _main(
    Rect anchor,
    Size content,
    OverlaySide side,
    double gap,
  ) => switch (side) {
    OverlaySide.bottom => anchor.bottom + gap,
    OverlaySide.top => anchor.top - gap - content.height,
    OverlaySide.right => anchor.right + gap,
    OverlaySide.left => anchor.left - gap - content.width,
  };

  static double _room(Rect anchor, Size bounds, OverlaySide side) =>
      switch (side) {
        OverlaySide.bottom => bounds.height - anchor.bottom,
        OverlaySide.top => anchor.top,
        OverlaySide.right => bounds.width - anchor.right,
        OverlaySide.left => anchor.left,
      };

  static OverlaySide _flip(
    Rect anchor,
    Size content,
    Size bounds,
    OverlaySide side,
    double gap,
    double padding,
  ) {
    final need =
        switch (side.vertical) {
          true => content.height,
          false => content.width,
        } +
        gap +
        padding;
    if (_room(anchor, bounds, side) >= need) return side;
    final other = side.opposite;
    final otherRoom = _room(anchor, bounds, other);
    if (otherRoom >= need || otherRoom > _room(anchor, bounds, side)) {
      return other;
    }
    return side;
  }

  @override
  bool operator ==(Object other) =>
      other is OverlayPosition &&
      other.offset == offset &&
      other.side == side &&
      other.anchorCenter == anchorCenter;

  @override
  int get hashCode => Object.hash(offset, side, anchorCenter);
}
