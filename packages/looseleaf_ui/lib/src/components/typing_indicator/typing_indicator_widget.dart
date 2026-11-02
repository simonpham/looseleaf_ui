import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show
        TypingParams,
        TypingPen,
        TypingVariant,
        typingGeometry,
        typingIndicatorRecipe;
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/typing_indicator/typing_indicator.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// "Someone is typing": three felt dots that pop in turn while a little
/// pencil hops along, or a cursive scrawl the pencil writes out.
///
/// It is a live region: while [active], screen readers hear [label].
/// Reduced motion keeps the marks still.
///
/// ```dart
/// TypingIndicator(variant: .squiggle, pen: .you)
/// ```
///
/// Mirrors upstream `src/components/ui/typing-indicator.tsx`. Upstream
/// animates the drawing's `dot-*`, `pencil` and `line` parts; here the same
/// frame is painted once per part, clipped to the part's region from
/// [typingGeometry], and that copy is moved.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    super.key,
    this.variant = TypingVariant.dots,
    this.pen = TypingPen.ink,
    this.pencil = true,
    this.active = true,
    this.label = 'Typing',
    this.seed,
  });

  final TypingVariant variant;

  /// The other person's ink or your blue.
  final TypingPen pen;

  /// Draw the little pencil.
  final bool pencil;

  /// Whether anyone is typing; false leaves an empty slot.
  final bool active;

  /// What screen readers announce.
  final String label;

  /// Pins the hand: the same seed always draws the same marks.
  final String? seed;

  /// The indicator's size per variant (`w-14 h-6`, `w-20 h-6`).
  static Size sizeOf(TypingVariant variant) => switch (variant) {
    TypingVariant.dots => const Size(Spacing.d56, Spacing.d24),
    TypingVariant.squiggle => const Size(
      Spacing.d80,
      Spacing.d24,
    ),
  };

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin, InkSeed {
  late final AnimationController _clock;

  Duration get _cycle => switch (widget.variant) {
    TypingVariant.dots => TypingIndicatorMotion.dotsCycle,
    TypingVariant.squiggle => TypingIndicatorMotion.squiggleCycle,
  };

  @override
  void initState() {
    super.initState();
    _clock = AnimationController.unbounded(
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final moving = widget.active && !InkMotion.reducedIn(context);
    if (!moving) {
      _clock.stop();
      _clock.value = _still;
      return;
    }
    if (_clock.isAnimating) return;
    _clock.value = 0;
    unawaited(_clock.animateWith(_Endless()));
  }

  static const double _still = 100;

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = TypingIndicator.sizeOf(widget.variant);
    final active = widget.active;
    return Semantics(
      container: true,
      liveRegion: true,
      label: switch (active) {
        true => widget.label,
        false => null,
      },
      child: SizedBox.fromSize(
        size: size,
        child: switch (active) {
          true => ExcludeSemantics(child: _parts(context, size)),
          false => null,
        },
      ),
    );
  }

  Widget _parts(BuildContext context, Size size) {
    final params = TypingParams(
      variant: widget.variant,
      pen: widget.pen,
      pencil: widget.pencil,
    );
    final source = RecipeInkSource(
      typingIndicatorRecipe,
      params,
      json: params.toJson(),
    );
    final seed = inkSeed(widget.seed);
    final geometry = typingGeometry(size.width, size.height, widget.variant);
    final pencilFrom = geometry.x1 + _pencilGap(size.height);
    Widget part(double left, double right) => Positioned.fill(
      child: ClipRect(
        clipper: _Band(left, right),
        child: InkSurface(source: source, seed: seed, still: true),
      ),
    );
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    return Transform.flip(
      flipX: rtl,
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) {
          final seconds = _clock.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              ...switch (widget.variant) {
                TypingVariant.dots => _dots(size, geometry, part, seconds),
                TypingVariant.squiggle => [
                  _wipe(
                    part(double.negativeInfinity, pencilFrom),
                    geometry.x0,
                    geometry.span,
                    TypingIndicatorMotion.wipe(_phase(seconds, Duration.zero)),
                  ),
                ],
              },
              if (widget.pencil)
                Transform.translate(
                  offset: Offset(
                    geometry.span *
                        switch (widget.variant) {
                          TypingVariant.dots => TypingIndicatorMotion.hop(
                            _phase(seconds, Duration.zero),
                          ),
                          TypingVariant.squiggle => TypingIndicatorMotion.walk(
                            _phase(seconds, Duration.zero),
                          ),
                        },
                    0,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [part(pencilFrom, double.infinity)],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _dots(
    Size size,
    ({double y, List<double> xs, double x0, double x1, double span}) geometry,
    Widget Function(double left, double right) part,
    double seconds,
  ) {
    final half = (geometry.xs[1] - geometry.xs[0]) / 2;
    return [
      for (final (index, x) in geometry.xs.indexed)
        Positioned.fill(
          child: Builder(
            builder: (context) {
              final (opacity, scale) = TypingIndicatorMotion.dot(
                _phase(seconds, TypingIndicatorMotion.dotStagger * index),
              );
              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  origin: Offset(
                    x - size.width / 2,
                    geometry.y - size.height / 2,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [part(x - half, x + half)],
                  ),
                ),
              );
            },
          ),
        ),
    ];
  }

  Widget _wipe(Widget line, double x0, double span, double shown) => ClipRect(
    clipper: _Band(double.negativeInfinity, x0 + span * shown + 2),
    child: Stack(clipBehavior: Clip.none, children: [line]),
  );

  double _phase(double seconds, Duration delay) {
    if (seconds >= _still) return 1;
    final cycle = _cycle.inMicroseconds / Duration.microsecondsPerSecond;
    final local =
        seconds - delay.inMicroseconds / Duration.microsecondsPerSecond;
    if (local < 0) return 0;
    return (local % cycle) / cycle;
  }

  static double _pencilGap(double h) => (h * 0.32).clamp(5, 9) - 3.5;
}

/// Clips to the vertical band from [left] to [right], unbounded vertically.
class _Band extends CustomClipper<Rect> {
  const _Band(this.left, this.right);

  final double left;
  final double right;

  static const double _reach = 1000;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    left.clamp(-_reach, _reach),
    -_reach,
    right.clamp(-_reach, _reach),
    _reach,
  );

  @override
  bool shouldReclip(_Band oldClipper) =>
      oldClipper.left != left || oldClipper.right != right;
}

/// A clock that counts seconds forever.
class _Endless extends Simulation {
  @override
  double x(double time) => time;

  @override
  double dx(double time) => 1;

  @override
  bool isDone(double time) => false;
}
