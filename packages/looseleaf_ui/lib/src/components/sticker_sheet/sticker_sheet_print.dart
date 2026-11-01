import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sticker_sheet/sticker_sheet.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What is printed on a sticker sheet's backing, filling it: a dashed
/// rounded frame with crop marks [top] px below the header, and on
/// [StickerSheetBacking.glassine] the sky tint and a diagonal sheen (gone
/// at calm density). Decorative.
///
/// Mirrors the `sticker-sheet-print` and `sticker-sheet-sheen` layers in
/// upstream `src/components/ui/sticker-sheet.tsx`.
class StickerSheetPrint extends StatelessWidget {
  const StickerSheetPrint({
    super.key,
    required this.backing,
    required this.seed,
    this.top = 0,
  });

  final StickerSheetBacking backing;

  /// Space above the printed frame (the header's), in pixels.
  final double top;

  /// Pins the hand.
  final String seed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final params = StickerSheetParams(top: top);
    final glassine = backing == StickerSheetBacking.glassine;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (glassine)
          ColoredBox(color: theme.colors.sky.withValues(alpha: 0.13)),
        if (glassine && !PaperInk.calm(theme))
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-0.93, -0.37),
                end: const Alignment(0.93, 0.37),
                colors: [
                  theme.colors.photo.withValues(alpha: 0),
                  theme.colors.photo.withValues(alpha: 0.42),
                  theme.colors.photo.withValues(alpha: 0),
                ],
                stops: const [0.3, 0.43, 0.56],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(Spacing.d6),
          child: InkSurface(
            source: RecipeInkSource(
              stickerSheetRecipe,
              params,
              json: params.toJson(),
            ),
            seed: '$seed|print',
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}
