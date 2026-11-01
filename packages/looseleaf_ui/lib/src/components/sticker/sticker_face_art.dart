import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';

/// One drawn [StickerFace] (or its kiss-cut line) at its drawn size,
/// overflow visible: the sticker art the sticker sheet, board and picker
/// lay out by the face's box. Decorative.
///
/// [face] is drawn by `stickerFace` from [name], [size], [seed], [peel] and
/// [idPrefix]; null when there is no such sticker. [kiss] paints the
/// kiss-cut line left on the backing instead of the sticker.
///
/// Mirrors the `<svg data-ink="sticker">` faces in upstream
/// `src/components/ui/sticker-sheet.tsx`, `sticker-board.tsx` and
/// `sticker-picker.tsx`.
class StickerFaceArt extends StatelessWidget {
  const StickerFaceArt({
    super.key,
    required this.name,
    required this.size,
    required this.seed,
    this.peel = false,
    this.idPrefix,
    this.shadow = true,
    this.kiss = false,
  });

  final String name;

  /// The sticker's size in pixels.
  final double size;

  /// Pins the hand.
  final String seed;

  /// Curls a corner up.
  final bool peel;

  /// The silhouette def ids' prefix.
  final String? idPrefix;

  /// The `ll-drop-sticker` drop shadow.
  final bool shadow;

  /// Paints the kiss-cut line around the face instead of the face.
  final bool kiss;

  /// The face this widget paints.
  StickerFace? get face => stickerFace(
    name,
    size,
    seed,
    peel: switch (peel) {
      true => const Peel.auto(),
      false => null,
    },
    idPrefix: idPrefix,
  );

  @override
  Widget build(BuildContext context) {
    final drawn = face;
    if (drawn == null) return const SizedBox.shrink();
    final svg = switch (kiss) {
      true => kissCut(drawn, '${idPrefix ?? 'll-sf'}k'),
      false => drawn.svg,
    };
    return InkArt(
      cacheKey:
          'sticker-face|$name|${JsMath.numberToString(size)}|$seed|$peel|'
          '${idPrefix ?? ''}|$kiss',
      draw: () => InkResult(
        svg: svg,
        w: drawn.w,
        h: drawn.h,
        pad: 12,
        layers: const [],
        parts: const {},
        bbox: BBox(0, 0, drawn.w, drawn.h),
      ),
      size: Size(drawn.w, drawn.h),
      shadow: shadow && !kiss,
    );
  }
}
