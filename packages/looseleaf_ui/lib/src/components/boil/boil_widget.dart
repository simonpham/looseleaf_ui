import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show boilKnobs, boilMaxFrames, boilSeed;
import 'package:looseleaf_ui/src/components/boil/boil_scope.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds boiling content for [frame]; [seed] reseeds a drawing's seed for
/// the frame.
typedef BoilBuilder =
    Widget Function(
      BuildContext context,
      int frame,
      String Function(String base) seed,
    );

/// Line boil: the ink below is redrawn a few times a second with slightly
/// different hands, the way hand-drawn animation shimmers.
///
/// Each frame multiplies the theme's knobs by [boilKnobs] and, through
/// [builder] or [BoilScope.seedOf], reseeds drawings with [boilSeed].
/// Reduced motion, calm density, [active] false or a muted [TickerMode]
/// hold it still on frame 0.
///
/// ```dart
/// Boil(
///   builder: (context, frame, seed) =>
///       Badge(seed: seed('new'), child: const Text('New')),
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/boil.tsx`. Upstream also reseeds
/// direct children through their `seed` prop; widgets cannot be cloned
/// that way, so use [builder] or [BoilScope.seedOf].
class Boil extends StatefulWidget {
  const Boil({
    super.key,
    this.child,
    this.builder,
    this.fps = 6,
    this.frames = 3,
    this.strength = 1,
    this.active = true,
  }) : assert(child != null || builder != null);

  /// Content that only picks up the boiling knobs.
  final Widget? child;

  /// Content built per frame, with a seed helper.
  final BoilBuilder? builder;

  /// Frames per second, 1 to 12.
  final double fps;

  /// Distinct frames, 2 to [boilMaxFrames].
  final int frames;

  /// How far frames stray from the base hand.
  final double strength;

  /// Whether it boils at all.
  final bool active;

  @override
  State<Boil> createState() => _BoilState();
}

class _BoilState extends State<Boil> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  int _frame = 0;

  int get _count => widget.frames.clamp(2, boilMaxFrames);

  Duration get _step => Duration(
    microseconds: (Duration.microsecondsPerSecond / widget.fps.clamp(1, 12))
        .round(),
  );

  bool _boiling(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return widget.active &&
        theme.density != LooseleafDensity.calm &&
        !InkMotion.reducedIn(context);
  }

  void _tick(Duration elapsed) {
    final next = (elapsed.inMicroseconds ~/ _step.inMicroseconds) % _count;
    if (next == _frame) return;
    setState(() => _frame = next);
  }

  void _sync() {
    final boiling = _boiling(context);
    if (boiling && !_ticker.isActive) {
      _ticker.start();
      return;
    }
    if (boiling) return;
    if (_ticker.isActive) _ticker.stop();
    _frame = 0;
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(Boil oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame % _count;
    final theme = LooseleafTheme.of(context);
    final boil = boilKnobs(frame, widget.strength);
    final knobs = theme.knobs;
    final data = switch (frame) {
      0 => theme,
      _ => theme.copyWith(
        knobs: LooseleafKnobs(
          wobble: knobs.wobble * boil.wobble,
          misreg: knobs.misreg * boil.misreg,
          bleed: knobs.bleed * boil.bleed,
          width: knobs.width * boil.width,
        ),
      ),
    };
    final builder = widget.builder;
    final body = switch (builder) {
      null => widget.child ?? const SizedBox.shrink(),
      _ => Builder(
        builder: (context) =>
            builder(context, frame, (base) => boilSeed(base, frame)),
      ),
    };
    return BoilScope(
      frame: frame,
      frames: _count,
      child: LooseleafTheme(data: data, child: body),
    );
  }
}
