import 'dart:math' as math;
import 'dart:ui';

/// Where an item-aligned [SelectContent] goes: Radix's `SelectItemAlignedPosition`.
///
/// The list opens so the aligned row's centre sits on the trigger's
/// centre. When that would leave the window, the list slides back inside
/// (keeping [margin]) and scrolls instead, so the row still lands on the
/// trigger as far as the list allows.
final class SelectPlacement {
  const SelectPlacement({
    required this.top,
    required this.height,
    required this.scroll,
  });

  /// The list's top edge, in overlay coordinates.
  final double top;

  /// The list's height.
  final double height;

  /// The list's scroll offset.
  final double scroll;

  /// Places a list of natural [listHeight] whose aligned row spans
  /// [rowTop] to [rowTop] + [rowHeight] (list coordinates) over [trigger]
  /// in an overlay of [bounds], no taller than [maxHeight].
  static SelectPlacement resolve({
    required Rect trigger,
    required Size bounds,
    required double listHeight,
    required double rowTop,
    required double rowHeight,
    double margin = 0,
    double maxHeight = double.infinity,
  }) {
    final room = math.max(0.0, bounds.height - margin * 2);
    final height = math.min(listHeight, math.min(room, maxHeight));
    final rowCenter = rowTop + rowHeight / 2;
    final ideal = trigger.center.dy - rowCenter;
    final lowest = math.max(margin, bounds.height - margin - height);
    final top = ideal.clamp(margin, lowest);
    final maxScroll = math.max(0.0, listHeight - height);
    final scroll = (rowCenter - (trigger.center.dy - top)).clamp(
      0.0,
      maxScroll,
    );
    return SelectPlacement(top: top, height: height, scroll: scroll);
  }

  @override
  bool operator ==(Object other) =>
      other is SelectPlacement &&
      other.top == top &&
      other.height == height &&
      other.scroll == scroll;

  @override
  int get hashCode => Object.hash(top, height, scroll);
}
