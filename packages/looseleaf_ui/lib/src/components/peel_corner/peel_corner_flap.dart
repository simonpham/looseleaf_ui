import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/peel_corner/peel_corner_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// The curled flap of a [PeelCorner]: drawn once at [size] and scaled from
/// its corner by the live peel, so a drag never redraws it. Decorative and
/// click-through.
///
/// Mirrors the `peel-corner-flap` part of upstream
/// `src/components/ui/peel-corner.tsx`.
class PeelCornerFlap extends StatefulWidget {
  const PeelCornerFlap({
    super.key,
    required this.size,
    required this.back,
    this.seed,
  });

  /// The flap's full size: the peel at scale 1.
  final double size;

  /// The paint of the flap's back.
  final PaintKey back;

  /// Pins the hand.
  final String? seed;

  @override
  State<PeelCornerFlap> createState() => _PeelCornerFlapState();
}

class _PeelCornerFlapState extends State<PeelCornerFlap> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final scope = PeelCornerScope.of(context);
    final left = scope.corner == PeelCornerSide.bottomLeft;
    final params = PeelFlapParams(back: widget.back, mirror: left);
    final flap = InkSurface(
      source: RecipeInkSource(peelFlapRecipe, params, json: params.toJson()),
      seed: inkSeed(widget.seed),
      still: true,
      child: SizedBox.square(dimension: widget.size),
    );
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ValueListenableBuilder<double>(
          valueListenable: scope.peel,
          builder: (context, peel, child) => Transform.scale(
            scale: peel / widget.size,
            alignment: switch (left) {
              true => Alignment.bottomLeft,
              false => Alignment.bottomRight,
            },
            child: child,
          ),
          child: flap,
        ),
      ),
    );
  }
}
