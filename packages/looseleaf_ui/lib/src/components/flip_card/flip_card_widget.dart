import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_axis.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_back.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_face.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_front.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_scope.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_trigger.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A card with two paper faces that turns over in 3D when pressed, lifting
/// off the desk as it turns: flash cards, answers, the back of a ticket.
///
/// Put a [FlipCardFront] and a [FlipCardBack] in [children]. The whole card
/// is a button (a [FlipCardTrigger] with a corner arrow) named [label];
/// with `trigger: false` the faces can hold their own buttons and you add a
/// trigger of your own. Uncontrolled it keeps its own side
/// ([defaultFlipped]); pass [flipped] and [onFlippedChange] to control it.
/// The card has a fixed size (288 × 192 by default) and turns around
/// [axis]. Where motion is reduced it swaps sides at once.
///
/// ```dart
/// const FlipCard(
///   label: 'Show the answer',
///   children: [
///     FlipCardFront(children: [Text('le chat')]),
///     FlipCardBack(children: [Text('the cat')]),
///   ],
/// )
/// ```
///
/// Mirrors `FlipCard` in upstream `src/components/ui/flip-card.tsx`.
class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.children,
    this.flipped,
    this.defaultFlipped = false,
    this.onFlippedChange,
    this.axis = FlipCardAxis.y,
    this.trigger = true,
    this.label = 'Flip card',
    this.width = defaultWidth,
    this.height = defaultHeight,
  });

  /// `w-72`.
  static const double defaultWidth = 288;

  /// `h-48`.
  static const double defaultHeight = 192;

  /// `perspective: 1200px`.
  static const double perspective = 1200;

  /// `translate: 0 -10px` at the top of the lift.
  static const double liftHeight = 10;

  /// `scale: 1.045` at the top of the lift.
  static const double liftScale = 0.045;

  /// Where in the turn the lift peaks.
  static const double liftPeak = 0.42;

  /// The two faces, then anything laid over the card (your own trigger in
  /// a [Positioned]).
  final List<Widget> children;

  /// Whether the back shows; null leaves the card uncontrolled.
  final bool? flipped;

  /// The first side of an uncontrolled card.
  final bool defaultFlipped;

  /// Called with the side the card is turning to.
  final ValueChanged<bool>? onFlippedChange;

  final FlipCardAxis axis;

  /// Covers the card with a [FlipCardTrigger].
  final bool trigger;

  /// The trigger's accessible name: say what happens ("Show the answer").
  final String label;

  /// The card's size.
  final double width;
  final double height;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with TickerProviderStateMixin {
  late bool _inner = widget.defaultFlipped;
  late final AnimationController _turn = AnimationController(
    vsync: this,
    value: switch (_flipped) {
      true => 1,
      false => 0,
    },
  );
  late final AnimationController _lift = AnimationController(vsync: this);
  double? _heading;

  bool get _flipped => widget.flipped ?? _inner;

  void _toggle() {
    final next = !_flipped;
    if (widget.flipped == null) setState(() => _inner = next);
    widget.onFlippedChange?.call(next);
    _sync();
    _lift.duration = InkMotion.of(context, InkMotion.sheet * 2);
    _lift.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final target = switch (_flipped) {
      true => 1.0,
      false => 0.0,
    };
    if (_turn.value == target || _turn.isAnimating && _heading == target) {
      return;
    }
    _heading = target;
    _turn.animateTo(
      target,
      duration: InkMotion.of(context, InkMotion.sheet * 2),
      curve: InkMotion.settle,
    );
  }

  @override
  void dispose() {
    _turn.dispose();
    _lift.dispose();
    super.dispose();
  }

  double get _liftAmount {
    final t = _lift.value;
    if (t <= 0 || t >= 1) return 0;
    if (t < FlipCard.liftPeak) {
      return InkMotion.easeOut.transform(t / FlipCard.liftPeak);
    }
    return 1 -
        InkMotion.easeOut.transform(
          (t - FlipCard.liftPeak) / (1 - FlipCard.liftPeak),
        );
  }

  Matrix4 _matrix() {
    final angle = _turn.value * math.pi;
    final lift = _liftAmount;
    final scale = 1 + FlipCard.liftScale * lift;
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 1 / FlipCard.perspective)
      ..translateByDouble(0, -FlipCard.liftHeight * lift, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
    switch (widget.axis) {
      case FlipCardAxis.x:
        matrix.rotateX(angle);
      case FlipCardAxis.y:
        matrix.rotateY(angle);
    }
    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    final faces = [
      for (final child in widget.children)
        if (child is FlipCardFront ||
            child is FlipCardBack ||
            child is FlipCardFace)
          Positioned.fill(child: child),
    ];
    final over = [
      for (final child in widget.children)
        if (child is! FlipCardFront &&
            child is! FlipCardBack &&
            child is! FlipCardFace)
          child,
    ];
    return FlipCardScope(
      flipped: _flipped,
      toggle: _toggle,
      axis: widget.axis,
      label: widget.label,
      turn: _turn,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_turn, _lift]),
                builder: (context, child) => Transform(
                  alignment: Alignment.center,
                  transform: _matrix(),
                  child: child,
                ),
                child: Stack(clipBehavior: Clip.none, children: faces),
              ),
            ),
            if (widget.trigger) const Positioned.fill(child: FlipCardTrigger()),
            ...over,
          ],
        ),
      ),
    );
  }
}
