import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
import 'package:looseleaf_ui/src/components/art/ink_art_cache.dart';
import 'package:looseleaf_ui/src/components/art/ink_art_painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Shows one piece of engine art (a whole SVG frame without state layers)
/// at [size], or at its drawn size: the shared body of `InkIcon`, `Doodle`,
/// `Sticker`, `Mascot` and `Stamp`.
///
/// [draw] runs once per [cacheKey]; the parse is kept in
/// [InkArtCache.shared]. The art paints past its box by its pad, like
/// upstream's `overflow-visible`, and takes no pointer input. It is
/// decorative unless [semanticLabel] names it (`role="img"`).
///
/// ```dart
/// InkArt(
///   cacheKey: 'stamp|Approved',
///   draw: () => stamp('Approved', StampShape.rect),
/// )
/// ```
class InkArt extends StatelessWidget {
  const InkArt({
    super.key,
    required this.cacheKey,
    required this.draw,
    this.size,
    this.color,
    this.shadow = false,
    this.drop,
    this.semanticLabel,
    this.flipX = false,
    this.flipY = false,
    this.rotation = 0,
  });

  /// Identifies the drawing: everything [draw] depends on.
  final String cacheKey;

  /// Draws the art.
  final ink.InkResult Function() draw;

  /// The box the viewBox is stretched over; the drawn size when null.
  final Size? size;

  /// `currentColor`; defaults to the ambient icon color, then the text
  /// color, then the ink token.
  final Color? color;

  /// The `ll-drop-sticker` drop shadow.
  final bool shadow;

  /// The drop shadow the art casts, like upstream `dropShadow(kind)`:
  /// `tape` and `prop` for paper props; wins over [shadow].
  final ink.DropKind? drop;

  /// Names the art for screen readers; decorative when null.
  final String? semanticLabel;

  /// Mirrors the art horizontally (`-scale-x-100`), paint only.
  final bool flipX;

  /// Mirrors the art vertically (`-scale-y-100`), paint only.
  final bool flipY;

  /// Turns the art by this many radians around its center (CSS `rotate`),
  /// paint only.
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final frame = InkArtCache.shared.frame(cacheKey, draw);
    final box = size ?? Size(frame.width, frame.height);
    final current =
        color ??
        context.dependOnInheritedWidgetOfExactType<IconTheme>()?.data.color ??
        DefaultTextStyle.of(context).style.color ??
        theme.colors.ink;
    Widget art = CustomPaint(
      size: box,
      painter: InkArtPainter(
        frame: frame,
        theme: theme,
        currentColor: current,
        shadow: shadow,
        drop: drop,
      ),
    );
    if (flipX || flipY) {
      art = Transform.flip(flipX: flipX, flipY: flipY, child: art);
    }
    if (rotation != 0) art = Transform.rotate(angle: rotation, child: art);
    final decorative = ExcludeSemantics(child: IgnorePointer(child: art));
    final label = semanticLabel;
    if (label == null) return decorative;
    return Semantics(
      container: true,
      image: true,
      label: label,
      child: decorative,
    );
  }
}
