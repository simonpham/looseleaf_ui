import 'dart:ui';

/// What the widget state does to elements inside a layer: `data-hide-on`
/// fades and `data-part` misregistration. [InkStateEffects.none] is rest.
class InkStateEffects {
  const InkStateEffects({this.hidden = const {}, this.partShift = 0});

  /// Rest: nothing hidden, nothing shifted.
  static const InkStateEffects none = InkStateEffects();

  /// State name to how visible elements hidden on it still are (1 → 0 as
  /// the state turns on). States at 1 can be left out.
  final Map<String, double> hidden;

  /// The multiplier on a `fill` part's `--mx` / `--my`, in px: 0 at rest,
  /// `--ll-hover-misreg` (0.35) on hover, `--ll-press-misreg` (-0.78) pressed.
  final double partShift;

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
}
