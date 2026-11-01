import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/marks/tools/tools.dart';
import 'package:looseleaf_ink/src/textures/textures.dart';

GrainKind? _grainOf(DrawTool tool) => switch (tool) {
  DrawTool.felt || DrawTool.brush => GrainKind.felt,
  DrawTool.pencil => GrainKind.graphite,
  DrawTool.marker => GrainKind.marker,
  DrawTool.highlighter => null,
};

final RegExp _cssVar = RegExp(r'var\((--ll-[a-z0-9-]+)\)');

/// [strokes] as a standalone SVG document of [width] × [height] (grown by
/// [margin] on every side), with the grain masks they need (tile images
/// from [uri]), an optional [background] fill and accessible [title].
/// [resolve] swaps `var(--ll-…)` paints for concrete colours; a null
/// answer keeps the variable.
///
/// Mirrors `strokesToSvg` in `src/lib/ink/recipes/sketchpad-ink.ts`.
String strokesToSvg(
  List<SketchStroke> strokes,
  TileUri uri, {
  required double width,
  required double height,
  Tier? tier,
  String? background,
  String? Function(String name)? resolve,
  double? margin,
  String? title,
}) {
  final t = tier ?? Tier.lo;
  final grains = <GrainKind>{};
  final body = StringBuffer();
  for (final s in strokes) {
    if (_grainOf(s.tool) case final g?) grains.add(g);
    body.write(
      '<g data-stroke="${esc(s.id)}">${strokeMarkup(s, tier: t).svg}</g>',
    );
  }
  final m = margin ?? 0;
  final w = width + 2 * m, h = height + 2 * m;
  final titled = title != null && title.isNotEmpty;
  final role = switch (titled) {
    true => ' role="img"',
    false => '',
  };
  final titleTag = switch (title) {
    final t? when titled => '<title>${esc(t)}</title>',
    _ => '',
  };
  final defs = switch (grains.isEmpty) {
    true => '',
    false => '<defs>${svgMaskDefs(uri, kinds: [...grains])}</defs>',
  };
  final bg = switch (background) {
    final b? when b.isNotEmpty =>
      '<rect x="${n(-m)}" y="${n(-m)}" width="${n(w)}" height="${n(h)}" fill="${esc(b)}"/>',
    _ => '',
  };
  final doc =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="${n(-m)} ${n(-m)} ${n(w)} ${n(h)}" '
      'width="${n(w)}" height="${n(h)}"$role>$titleTag$defs$bg'
      '<g isolation="isolate">$body</g></svg>';
  if (resolve == null) return doc;
  return doc.replaceAllMapped(_cssVar, (match) {
    final whole = match[0] ?? '';
    return switch (resolve(match[1] ?? '')) {
      final v? when v.isNotEmpty => v,
      _ => whole,
    };
  });
}
