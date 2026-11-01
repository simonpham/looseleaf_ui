import 'dart:ui';

/// What the widget state does to elements inside a layer: `data-hide-on`
/// fades, `data-part` misregistration and the `swipe` / `reveal` part
/// animations. [InkStateEffects.none] is rest.
class InkStateEffects {
  const InkStateEffects({
    this.hidden = const {},
    this.partShift = 0,
    this.swipe = 1,
    this.reveal = 1,
  });

  /// Rest: nothing hidden, nothing shifted.
  static const InkStateEffects none = InkStateEffects();

  /// State name to how visible elements hidden on it still are (1 → 0 as
  /// the state turns on). States at 1 can be left out.
  final Map<String, double> hidden;

  /// The multiplier on a `fill` part's `--mx` / `--my`, in px: 0 at rest,
  /// `--ll-hover-misreg` (0.35) on hover, `--ll-press-misreg` (-0.78) pressed.
  final double partShift;

  /// How far a `swipe` part has wiped in (0 → 1), upstream's `ll-wipe`
  /// keyframes (`clip-path: inset(...)`); 1 shows it whole.
  final double swipe;

  /// How far a `reveal` part has been drawn on (0 → 1), upstream's `ll-draw`
  /// keyframes (`stroke-dashoffset` 1 → 0 over `stroke-dasharray: 1`); 1
  /// shows it whole.
  final double reveal;

  /// The opacity of an element with `data-hide-on` [states].
  double opacityFor(Set<String> states) {
    var opacity = 1.0;
    for (final state in states) {
      final value = hidden[state];
      if (value != null && value < opacity) opacity = value;
    }
    return opacity;
  }

  /// The translation of a part.
  Offset shiftFor(String? part, Offset misregister) {
    if (part != 'fill' || partShift == 0) return Offset.zero;
    return misregister * partShift;
  }

  /// The clip of a part with painted [bounds]: a `swipe` part is cut to the
  /// part of its box wiped in so far, from the reading start; null when
  /// nothing is cut.
  Rect? clipFor(String? part, Rect? bounds, TextDirection direction) {
    if (part != 'swipe' || swipe >= 1 || bounds == null) return null;
    final outside = bounds.width * 0.04;
    final shown = (bounds.width + outside) * swipe;
    final vertical = bounds.height * 0.1;
    return switch (direction) {
      TextDirection.ltr => Rect.fromLTRB(
        bounds.left - outside,
        bounds.top - vertical,
        bounds.left + shown,
        bounds.bottom + vertical,
      ),
      TextDirection.rtl => Rect.fromLTRB(
        bounds.right - shown,
        bounds.top - vertical,
        bounds.right + outside,
        bounds.bottom + vertical,
      ),
    };
  }
}
