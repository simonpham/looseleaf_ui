import 'dart:math' as math;

/// Where a [Carousel] lines a slide up in the view when it rests on it
/// (Embla's `align` option).
enum CarouselAlign {
  /// The slide's start meets the view's start.
  start,

  /// The slide sits in the middle of the view (Embla's default).
  center,

  /// The slide's end meets the view's end.
  end,
}

/// The offsets a carousel can rest on, in view lengths (the view plus one
/// gap, so a slide's pitch is its fraction): Embla's scroll snaps with
/// `containScroll: "trimSnaps"`, clamped to the strip and deduplicated, or
/// one per slide when it loops.
List<double> carouselSnaps({
  required int count,
  required double fraction,
  required CarouselAlign align,
  required bool loop,
}) {
  if (count == 0) return const [];
  final max = math.max(0.0, count * fraction - 1);
  final snaps = <double>[];
  for (var index = 0; index < count; index++) {
    final start = index * fraction;
    final raw = switch (align) {
      CarouselAlign.start => start,
      CarouselAlign.center => start + fraction / 2 - 0.5,
      CarouselAlign.end => start + fraction - 1,
    };
    final snap = raw.clamp(0.0, max);
    if (loop) {
      snaps.add(math.min(start, max));
      continue;
    }
    if (snaps.isNotEmpty && (snap - snaps.last).abs() < 1e-6) continue;
    snaps.add(snap);
  }
  return snaps;
}

/// The index of the snap in [snaps] nearest to [offset].
int nearestCarouselSnap(List<double> snaps, double offset) {
  var best = 0;
  for (final (index, snap) in snaps.indexed) {
    if ((snap - offset).abs() < (snaps[best] - offset).abs()) best = index;
  }
  return best;
}
