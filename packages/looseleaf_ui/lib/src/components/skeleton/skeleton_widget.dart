import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/skeleton/skeleton.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A placeholder while content loads: a pale wash, pencil hatching and a
/// ruled pencil outline, redrawn three times over, slowly (a boil). Give it
/// the shape of what is coming: text lines, a [circle] for an avatar, a
/// picture.
///
/// The boil stops in calm density and where motion is reduced. Decorative:
/// mark the loading region busy instead.
///
/// ```dart
/// const Skeleton(width: 250, height: Spacing.d16)
/// const Skeleton(width: Spacing.d48, height: Spacing.d48, circle: true)
/// ```
///
/// Mirrors upstream `src/components/ui/skeleton.tsx`.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.circle = false,
    this.child,
    this.seed,
  });

  /// The width; null fills the incoming constraints (`w-full`).
  final double? width;

  /// The height; null fills the incoming constraints.
  final double? height;

  /// A round placeholder (upstream `rounded-full`), outlined by a pencil
  /// circle.
  final bool circle;

  /// Content laid over the placeholder, rarely needed.
  final Widget? child;

  /// Picks the boil phase, so neighbouring skeletons do not boil in step.
  final String? seed;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with InkSeed, SingleTickerProviderStateMixin {
  static const Duration _boil = Duration(milliseconds: 1080);

  final ValueNotifier<int> _frame = ValueNotifier(0);
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: _boil,
  )..addListener(_tick);

  int get _phase => hashSeed(inkSeed(widget.seed)) % skeletonFrames;

  void _tick() {
    final step = (_clock.value * skeletonFrames).floor();
    _frame.value = (_phase + step) % skeletonFrames;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still =
        InkMotion.reducedIn(context) ||
        LooseleafTheme.of(context).density == LooseleafDensity.calm;
    if (still) {
      _clock.stop();
      _frame.value = 0;
      return;
    }
    if (_clock.isAnimating) return;
    _tick();
    _clock.repeat();
  }

  @override
  void dispose() {
    _clock.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: SkeletonPainter(
      frame: _frame,
      theme: LooseleafTheme.of(context),
      circle: widget.circle,
      repaint: _frame,
    ),
    child: SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: widget.child,
    ),
  );
}
