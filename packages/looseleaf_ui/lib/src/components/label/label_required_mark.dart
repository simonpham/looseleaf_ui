import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

const ArtDef _star = ArtDef(
  kind: ArtKind.icon,
  grid: ArtGrid.icon,
  parts: [
    StrokePart('M12.3 4.4 L11.7 19.6', 1.25),
    StrokePart('M4.9 8.3 L19.3 15.9', 1.25),
    StrokePart('M18.7 8.6 L6.4 15.4', 1.25),
  ],
  small: [
    StrokePart('M12.4 3.4 L11.6 20.6', 1.05),
    StrokePart('M3.9 7.6 L20.2 16.6', 1.05),
    StrokePart('M19.4 7.9 L5.4 16.1', 1.05),
  ],
);

/// The red pencil star a [Label] draws after a required field's name.
///
/// Decorative: it is excluded from semantics, the field itself says it is
/// required. Mirrors `RequiredMark` in upstream
/// `src/components/ui/label.tsx`.
class LabelRequiredMark extends StatelessWidget {
  const LabelRequiredMark({
    super.key,
    required this.seed,
    this.size = Spacing.d12,
  });

  /// Pins the hand: the same seed always draws the same star.
  final String seed;

  /// The star's side; upstream's `size-[0.8em]` of the 15 px label.
  final double size;

  @override
  Widget build(BuildContext context) {
    final side = size;
    return InkArt(
      cacheKey: 'label-star|$seed|$side',
      draw: () => drawSkeleton(
        _star,
        side,
        seed,
        const DrawOpts(tone: ArtTone.ui, kind: ArtKind.icon),
      ).result,
      size: Size.square(side),
      color: LooseleafTheme.of(context).colors.red,
    );
  }
}
