import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Things lying about the desk, filling its parent behind the paper: a
/// coffee ring, a pencil, paper clips, a ruler, push pins. Hidden on narrow
/// layouts (under 640 px) and at calm density; decorative.
///
/// Mirrors `DeskObjects` in upstream `src/components/ui/desk.tsx`.
class DeskObjects extends StatefulWidget {
  const DeskObjects({super.key, required this.objects, this.seed});

  /// Narrower than this, the objects are put away (upstream's `max-sm`).
  static const double minWidth = 640;

  /// What lies on the desk.
  final List<DeskObject> objects;

  /// Pins the drawings.
  final String? seed;

  @override
  State<DeskObjects> createState() => _DeskObjectsState();
}

class _DeskObjectsState extends State<DeskObjects> with InkSeed {
  static double _radians(double degrees) => degrees * math.pi / 180;

  Widget _art(String key, InkResult Function() draw, {bool drop = true}) =>
      InkArt(
        cacheKey: key,
        draw: draw,
        drop: switch (drop) {
          true => DropKind.prop,
          false => null,
        },
      );

  Widget _place(DeskObject object, String seed, Tier tier, bool calm) {
    String key(String part) => '$part|$seed|${tier.name}|$calm';
    return switch (object) {
      DeskObject.coffee => PositionedDirectional(
        bottom: -Spacing.d48,
        end: -Spacing.d40,
        child: Transform.rotate(
          angle: _radians(6),
          child: _art(
            key('coffee'),
            () =>
                coffeeRing('$seed:coffee', radius: 64, tier: tier, calm: calm),
            drop: false,
          ),
        ),
      ),
      DeskObject.pencil => PositionedDirectional(
        bottom: Spacing.d64,
        start: Spacing.d40,
        child: Transform.rotate(
          angle: _radians(-24),
          alignment: AlignmentDirectional.centerStart,
          child: _art(
            key('pencil'),
            () => pencilProp(
              '$seed:pencil',
              length: 200,
              tier: tier,
              calm: calm,
            ),
          ),
        ),
      ),
      DeskObject.clips => PositionedDirectional(
        top: Spacing.d20,
        end: Spacing.d112,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d8,
          children: [
            Transform.rotate(
              angle: _radians(12),
              child: _art(
                key('clip-a'),
                () => paperClip(
                  '$seed:clip-a',
                  height: 62,
                  tier: tier,
                  calm: calm,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -Spacing.d4),
              child: Transform.rotate(
                angle: _radians(-9),
                child: _art(
                  key('clip-b'),
                  () => paperClip(
                    '$seed:clip-b',
                    height: 58,
                    tone: Accent.sky,
                    tier: tier,
                    calm: calm,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      DeskObject.ruler => PositionedDirectional(
        bottom: -Spacing.d4,
        start: 0,
        end: 0,
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: EdgeInsetsDirectional.only(
              start: constraints.maxWidth * 0.38,
            ),
            child: Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Transform.rotate(
                angle: _radians(-1.4),
                child: _art(
                  key('ruler'),
                  () => rulerProp(
                    '$seed:ruler',
                    300,
                    height: 30,
                    tier: tier,
                    calm: calm,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      DeskObject.pins => PositionedDirectional(
        top: Spacing.d16,
        start: Spacing.d96,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d8,
          children: [
            _art(
              key('pin-a'),
              () => pushPin(
                '$seed:pin-a',
                size: 22,
                tier: tier,
                calm: calm,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Spacing.d16),
              child: _art(
                key('pin-b'),
                () => pushPin(
                  '$seed:pin-b',
                  size: 24,
                  color: Accent.sky,
                  tier: tier,
                  calm: calm,
                ),
              ),
            ),
          ],
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final calm = PaperInk.calm(theme);
    if (calm || widget.objects.isEmpty) return const SizedBox.shrink();
    final seed = inkSeed(widget.seed);
    final tier = PaperInk.tier(theme);
    return ExcludeSemantics(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < DeskObjects.minWidth) {
              return const SizedBox.shrink();
            }
            return ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  for (final object in widget.objects)
                    _place(object, seed, tier, calm),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
