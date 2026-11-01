import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/polaroid/polaroid.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A polaroid's photo window: square, recessed with an inner shadow,
/// clipping [child] (an `Image` with `fit: BoxFit.cover` fills it). Or a
/// little [scene] drawn in marker and felt tip, for placeholders.
///
/// [date] prints a camera's orange date stamp in the end corner, [develop]
/// starts the picture milky and clears it. A drawn scene is decoration
/// unless [label] names it.
///
/// Mirrors `PolaroidImage` in upstream `src/components/ui/polaroid.tsx`.
class PolaroidImage extends StatefulWidget {
  const PolaroidImage({
    super.key,
    this.child,
    this.scene,
    this.date,
    this.develop = false,
    this.label,
    this.seed,
  });

  /// The photograph.
  final Widget? child;

  /// A drawn scene: hills, sea, a house or a night sky.
  final PolaroidScene? scene;

  /// A date stamp like `'25 8 09`; decorative, so say it elsewhere when it
  /// matters.
  final String? date;

  /// Starts milky and clears over half a second, once per mount.
  final bool develop;

  /// Names a drawn [scene] as an image.
  final String? label;

  /// Pins the scene's hand.
  final String? seed;

  @override
  State<PolaroidImage> createState() => _PolaroidImageState();
}

class _PolaroidImageState extends State<PolaroidImage> with InkSeed {
  Widget? _scene() {
    final scene = widget.scene;
    if (scene == null) return null;
    final params = PolaroidPhotoParams(scene: scene);
    final drawing = InkSurface(
      source: RecipeInkSource(
        polaroidPhotoRecipe,
        params,
        json: params.toJson(),
      ),
      seed: inkSeed(widget.seed),
      still: true,
    );
    if (widget.label case final label?) {
      return Semantics(image: true, label: label, child: drawing);
    }
    return ExcludeSemantics(child: drawing);
  }

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: colors.paperShade.withValues(alpha: 0.6)),
            ?_scene(),
            ?widget.child,
            IgnorePointer(
              child: CustomPaint(
                painter: PolaroidWindowShadow(shade: colors.shade),
              ),
            ),
            if (widget.date case final date?)
              PositionedDirectional(
                end: Spacing.d10,
                bottom: Spacing.d8,
                child: PolaroidDate(date),
              ),
            if (widget.develop) const PolaroidVeil(),
          ],
        ),
      ),
    );
  }
}
