import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The ribbon's shape: a banner with folded tails, a swallowtail or a flag.
enum RibbonVariant { banner, swallow, flag }

/// Ribbon sizes; `id` is the upstream name (`regular` is upstream's
/// `default`). [band] is the band height, [tail] the banner tail length,
/// [drop] how far the tails hang below the band, [text] the Tailwind text
/// class and [font] the label size.
enum RibbonSize {
  sm('sm', band: 26, tail: 14, drop: 6, text: 'text-sm', font: 14),
  regular('default', band: 34, tail: 20, drop: 9, text: 'text-base', font: 16),
  lg('lg', band: 46, tail: 28, drop: 12, text: 'text-xl', font: 20);

  const RibbonSize(
    this.id, {
    required this.band,
    required this.tail,
    required this.drop,
    required this.text,
    required this.font,
  });

  /// The upstream name.
  final String id;
  final double band;
  final double tail;
  final double drop;
  final String text;
  final double font;
}

/// Ribbon fill tones.
enum RibbonTone {
  marker(PaintKey.marker),
  hi(PaintKey.hi),
  tangerine(PaintKey.tangerine),
  lemon(PaintKey.lemon),
  grass(PaintKey.grass),
  teal(PaintKey.teal),
  sky(PaintKey.sky),
  bubblegum(PaintKey.bubblegum),
  paper(PaintKey.paper);

  const RibbonTone(this.paint);

  /// The fill paint.
  final PaintKey paint;
}

/// The room the label leaves at each end of the band.
///
/// Mirrors `ribbonGutter` in `src/lib/ink/recipes/ribbon-ink.ts`.
double ribbonGutter(RibbonVariant variant) => switch (variant) {
  RibbonVariant.flag => 12,
  _ => 14,
};

/// How far the band is inset from the box ends (the tail or notch).
///
/// Mirrors `ribbonInset` in `src/lib/ink/recipes/ribbon-ink.ts`.
double ribbonInset(RibbonVariant variant, RibbonSize size) => switch (variant) {
  RibbonVariant.banner => size.tail,
  _ => JsMath.round(size.band * 0.32),
};

/// How far the tails hang below the band.
///
/// Mirrors `ribbonDrop` in `src/lib/ink/recipes/ribbon-ink.ts`.
double ribbonDrop(RibbonVariant variant, RibbonSize size) => switch (variant) {
  RibbonVariant.banner => size.drop,
  _ => 0,
};

/// Ribbon recipe params.
///
/// Mirrors `RibbonParams` in `src/lib/ink/recipes/ribbon-ink.ts`.
final class RibbonParams {
  /// Params.
  const RibbonParams({
    required this.variant,
    required this.tone,
    required this.size,
    this.hoverable,
  });

  final RibbonVariant variant;
  final RibbonTone tone;
  final RibbonSize size;
  final bool? hoverable;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'variant': variant.name,
    'tone': tone.name,
    'size': size.id,
    if (hoverable case final bool v) 'hoverable': v,
  };
}

List<Pt> _closed(List<Pt> pts) => [...pts, pts[0]];

List<Pt> _mirror(List<Pt> pts, double w) => [
  for (final (x, y) in pts) (w - x, y),
].reversed.toList();

/// A ribbon banner: marker band, folded tails on the banner, an underline
/// and drop rule on hover, a lazy focus ring.
///
/// Mirrors `ribbonRecipe` in `src/lib/ink/recipes/ribbon-ink.ts`.
final Recipe<RibbonParams> ribbonRecipe = defineRecipe<RibbonParams>(
  id: 'ribbon',
  kind: 'ribbon',
  layers: const [LayerName.rest, LayerName.hover, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, RibbonParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final variant = params.variant;
  final s = params.size;
  final drop = ribbonDrop(variant, s);
  final bandH = h - drop;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 3));
  if (ctx.lazyOnly) return;
  final fill = params.tone.paint;
  final tailLen = switch (variant) {
    RibbonVariant.banner => s.tail,
    _ => ribbonInset(variant, s),
  };
  final notch = clamp(bandH * 0.28, 5, 14);
  final outline = switch (ctx.calm) {
    true => PenName.pencilFine,
    false => PenName.ink,
  };
  final fine = switch (ctx.calm) {
    true => PenName.pencilFine,
    false => PenName.inkFine,
  };

  ink.layer(LayerName.rest, () {
    if (variant == RibbonVariant.banner) {
      final fold = clamp(drop * 1.2, 6, 18);
      final left = <Pt>[
        (tailLen, drop),
        (0.5, drop),
        (notch, drop + (bandH - 0.5) / 2),
        (0.5, h - 0.5),
        (tailLen, h - 0.5),
      ];
      final right = _mirror(left, w);
      final foldL = <Pt>[
        (tailLen, bandH),
        (tailLen + fold, bandH),
        (tailLen, h - 0.5),
      ];
      final foldR = _mirror(foldL, w);
      ink.part('fill', () {
        var off = InkOffset.zero;
        for (final piece in [left, right, foldL, foldR]) {
          off = blobFill(ink, piece, fill, alpha: 0.95);
        }
        return off;
      });
      for (final tail in [left, right]) {
        wash(ink, tail, PaintKey.ink, alpha: 0.16, inset: 0.5);
        ink.stroke(
          _closed(tail),
          fine,
          const StrokeOpts(poly: true, round: 1.2, simple: true),
        );
      }
      for (final f in [foldL, foldR]) {
        wash(ink, f, PaintKey.ink, alpha: 0.4, inset: 0.3);
        ink.stroke(
          _closed(f),
          PenName.inkFine,
          const StrokeOpts(poly: true, round: 0.8, simple: true),
        );
      }
    }
    List<Pt> flip(List<Pt> pts) => switch (ctx.dir) {
      Dir.rtl => _mirror(pts, w),
      Dir.ltr => pts,
    };
    final band = switch (variant) {
      RibbonVariant.banner => <Pt>[
        (tailLen, 1.5),
        (w - tailLen, 1.5),
        (w - tailLen, bandH - 1.5),
        (tailLen, bandH - 1.5),
      ],
      RibbonVariant.swallow => <Pt>[
        (1.5, 1.5),
        (w - 1.5, 1.5),
        (w - 1.5 - notch, bandH / 2),
        (w - 1.5, bandH - 1.5),
        (1.5, bandH - 1.5),
        (1.5 + notch, bandH / 2),
      ],
      RibbonVariant.flag => flip([
        (1.5, 1.5),
        (w - 1.5, 1.5),
        (w - 1.5 - notch, bandH / 2),
        (w - 1.5, bandH - 1.5),
        (1.5, bandH - 1.5),
      ]),
    };
    ink.part(
      'fill',
      () => bandFill(
        ink,
        band,
        fill,
        passes: switch (ctx.calm) {
          true => 1,
          false => 2,
        },
        ends: switch (ctx.calm) {
          true => BandEnds.square,
          false => null,
        },
      ),
    );
    if (variant == RibbonVariant.banner) {
      box(ink, tailLen, 0, w - 2 * tailLen, bandH, pen: outline, corner: 2);
      return;
    }
    ink.stroke(
      _closed(band),
      outline,
      const StrokeOpts(poly: true, round: 1.4),
    );
  });

  if (params.hoverable != true) return;
  ink.layer(LayerName.hover, () {
    final gutter = tailLen + ribbonGutter(variant);
    if (w - 2 * gutter > 12) {
      underline(
        ink,
        gutter,
        bandH / 2 + s.font * 0.56,
        w - 2 * gutter,
        kind: UnderlineKind.single,
        pen: PenName.inkFine,
        opts: const StrokeOpts(simple: true),
      );
    }
    final y = bandH + 3.5;
    final x0 = switch (variant) {
      RibbonVariant.banner => tailLen + 4,
      _ => 6.0,
    };
    final x1 = switch (variant) {
      RibbonVariant.banner => w - tailLen - 4,
      _ => w - 8,
    };
    ink.lines(
      [
        Line([(x0, y), (x1, y)], o: ruler),
      ],
      PenName.inkFine,
      const StrokeOpts(width: 1.2),
    );
  });
}
