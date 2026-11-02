import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/spinner/spinner.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A busy indicator, three ways: a pen spiral scribbled round and round
/// ([SpinnerVariant.scribble]), a row of loops written along a line
/// ([SpinnerVariant.loops]), or Stubby the mascot writing
/// ([SpinnerVariant.write]).
///
/// The scribble and loops take the text color. Where motion is reduced they
/// hold still: the whole mark, or Stubby's last frame.
///
/// ```dart
/// const Spinner()
/// const Spinner(variant: SpinnerVariant.loops, size: Spacing.d20)
/// ```
///
/// Mirrors upstream `src/components/ui/spinner.tsx`.
class Spinner extends StatefulWidget {
  const Spinner({
    super.key,
    this.variant = SpinnerVariant.scribble,
    this.size,
    this.seed,
    this.semanticLabel = 'Loading',
  });

  final SpinnerVariant variant;

  /// The mark's size in px: the spiral's side, the loops' height (they are
  /// four times as wide) or Stubby's height. Defaults to 16, and 64 for
  /// [SpinnerVariant.write].
  final double? size;

  /// Pins the hand: the same seed always draws the same mark.
  final String? seed;

  /// What screen readers announce.
  final String semanticLabel;

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner>
    with InkSeed, SingleTickerProviderStateMixin {
  /// `calc(var(--ll-dur-draw) * 2)`, one scribble lap.
  static const Duration _drawLap = Duration(milliseconds: 1200);

  /// `--ll-write-lap`: `calc(var(--ll-dur-boil) * 2.25)`.
  static const Duration _writeLap = Duration(milliseconds: 1080);

  /// The scribble's moving dash: `stroke-dasharray: .42 .58`.
  static const List<double> _dashes = [0.42, 0.58];

  static const int _writeFrames = 3;

  late final AnimationController _clock;
  bool _still = false;

  bool get _writes => widget.variant == SpinnerVariant.write;

  double get _px {
    final asked =
        widget.size ??
        switch (_writes) {
          true => Spacing.d64,
          false => Spacing.d16,
        };
    return math.max(8, asked.roundToDouble());
  }

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = InkMotion.reducedIn(context);
    _run();
  }

  @override
  void didUpdateWidget(Spinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variant != widget.variant) _run();
  }

  void _run() {
    if (_still) {
      _clock.stop();
      return;
    }
    _clock
      ..duration = switch (_writes) {
        true => _writeLap,
        false => _drawLap,
      }
      ..repeat();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: widget.semanticLabel,
    child: ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => switch (_writes) {
          true => _write(context),
          false => _mark(context),
        },
      ),
    ),
  );

  Widget _mark(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final loops = widget.variant == SpinnerVariant.loops;
    final px = _px;
    final seed = inkSeed(widget.seed);
    final tier = switch (theme.effectiveTier) {
      LooseleafTier.lo => Tier.lo,
      LooseleafTier.hi => Tier.hi,
    };
    final calm = theme.density == LooseleafDensity.calm;
    final frame = InkArtCache.shared.frame(
      'spinner|$seed|$px|$loops|${tier.name}|$calm',
      () => switch (loops) {
        true => spinnerMark(
          seed,
          px,
          shape: SpinnerShape.loops,
          w: px * 4,
          h: px,
          tier: tier,
          calm: calm,
        ),
        false => spinnerMark(seed, px, tier: tier, calm: calm),
      },
    );
    final painter = SpinnerPainter(
      frame: frame,
      theme: theme,
      color: DefaultTextStyle.of(context).style.color ?? theme.colors.ink,
      effects: switch (_still) {
        true => InkStateEffects.none,
        false => InkStateEffects(reveal: _clock.value, revealDashes: _dashes),
      },
    );
    return CustomPaint(
      size: switch (loops) {
        true => painter.viewBox.size,
        false => Size.square(px),
      },
      painter: painter,
    );
  }

  Widget _write(BuildContext context) {
    final frame = switch (_still) {
      true => _writeFrames,
      false => math.min(
        _writeFrames,
        (_clock.value * _writeFrames).floor() + 1,
      ),
    };
    final seed = inkSeed(widget.seed);
    final px = _px;
    final id = 'write-$frame';
    return InkArt(
      cacheKey: 'spinner|$id|$px|$seed',
      draw: () => drawMascot(
        mascotFrames[id] ?? mascotFrames.values.first,
        px,
        seed,
        MascotDrawOpts(idPrefix: 'll-$seed${id.replaceAll('-', '')}'),
      ).result,
      shadow: true,
    );
  }
}
