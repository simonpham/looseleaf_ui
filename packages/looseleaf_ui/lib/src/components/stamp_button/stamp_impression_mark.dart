import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/stamp/stamp.dart';
import 'package:looseleaf_ui/src/components/stamp_button/stamp_impression.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Shows one [StampImpression] as a [Stamp]. When [thump] is true it lands
/// like a strike: it fades in from 1.7 times its size with the pop curve.
///
/// Mirrors the `stamp-impression` part of upstream
/// `src/components/ui/stamp-button.tsx`.
class StampImpressionMark extends StatelessWidget {
  const StampImpressionMark({
    super.key,
    required this.impression,
    this.thump = false,
  });

  final StampImpression impression;

  /// Whether to land with the strike animation.
  final bool thump;

  static const double _from = 1.7;

  @override
  Widget build(BuildContext context) {
    final i = impression;
    final stamp = Stamp(
      name: i.name,
      text: i.text,
      shape: i.shape,
      ink: i.ink,
      sub: i.sub,
      ring: i.ring,
      w: i.w,
      h: i.h,
      size: i.size,
      ghost: i.ghost,
      dashed: i.dashed,
      seed: i.seed,
    );
    final duration = InkMotion.of(context, InkMotion.pop);
    if (!thump || duration == Duration.zero) return stamp;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: InkMotion.popCurve,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: _from + (1 - _from) * t, child: child),
      ),
      child: stamp,
    );
  }
}
