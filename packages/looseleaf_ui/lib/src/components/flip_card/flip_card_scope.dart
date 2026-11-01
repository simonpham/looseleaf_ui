import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_axis.dart';

/// What a [FlipCard] tells its parts: which side shows, how to turn it,
/// the axis, the trigger's name and the turn's progress.
///
/// Mirrors `useFlipCard` in upstream `src/components/ui/flip-card.tsx`:
/// call [toggle] from your own button to turn the card.
class FlipCardScope extends InheritedWidget {
  const FlipCardScope({
    super.key,
    required this.flipped,
    required this.toggle,
    required this.axis,
    required this.label,
    required this.turn,
    required super.child,
  });

  /// Whether the back shows.
  final bool flipped;

  /// Turns the card over.
  final VoidCallback toggle;

  final FlipCardAxis axis;

  /// The trigger's accessible name.
  final String label;

  /// The turn, 0 (front up) to 1 (back up).
  final Animation<double> turn;

  /// The enclosing card's scope.
  static FlipCardScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FlipCardScope>();
    if (scope == null) {
      throw FlutterError('FlipCard parts must be used inside a FlipCard.');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(FlipCardScope oldWidget) =>
      oldWidget.flipped != flipped ||
      oldWidget.axis != axis ||
      oldWidget.label != label ||
      oldWidget.toggle != toggle ||
      oldWidget.turn != turn;
}
