import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/face_path.dart';
import 'package:looseleaf_ink/src/paper/face_spec.dart';
import 'package:looseleaf_ink/src/paper/shadows.dart';
import 'package:looseleaf_ink/src/paper/stocks.dart';
import 'package:looseleaf_ink/src/textures/paper_tiles.dart';

/// The paper tiles the faces of [stocks] need, in first-use order.
///
/// Mirrors `tilesOf` in `src/lib/ink/paper/faces.ts`.
List<PaperTileName> tilesOf(Iterable<StockName> stocks) => {
  for (final s in stocks) ...?toothTiles[stockOf(s).tooth],
}.toList();

/// A face's CSS: its classes and custom properties.
final class FaceLook {
  /// A look.
  const FaceLook(this.className, this.vars);

  /// Space-separated CSS classes.
  final String className;

  /// CSS custom properties.
  final Map<String, String> vars;
}

/// The CSS classes and variables that paint a face of [stock].
///
/// Mirrors `faceLook` in `src/lib/ink/paper/faces.ts`.
FaceLook faceLook(StockName stock, Object seed, [bool veil = true]) {
  final s = stockOf(stock);
  final vars = <String, String>{};
  final noTooth = s.tooth == Tooth.none;
  if (noTooth) {
    vars['--ll-tex-paper'] = 'var(--ll-tex-cloud)';
    vars['--ll-tex-paper-size'] = '720px 720px';
  }
  vars['--ll-tex-paper-pos'] = switch (noTooth) {
    true => tileOffsets(seed, const [(720, 720)]),
    false => tileOffsets(seed, toothTileSizes(s.tooth)),
  };
  if (s.gum && veil) {
    vars['--ll-veil'] = '${JsMath.roundInt(stickyVeil * 100)}%';
  }
  if (s.stockClass.isEmpty) vars['--ll-stock'] = s.color;
  final className = [
    s.stockClass,
    s.toothClass,
  ].where((c) => c.isNotEmpty).join(' ');
  return FaceLook(className, vars);
}

/// The CSS `clip-path` of a face, moved by `(dx, dy)`.
///
/// Mirrors `faceClip` in `src/lib/ink/paper/faces.ts`.
String faceClip(FaceSpec spec, [double dx = 0, double dy = 0]) {
  final rule = switch (spec.evenodd) {
    true => 'evenodd, ',
    false => '',
  };
  final d = switch (dx != 0 || dy != 0) {
    true => translatePath(spec.d, dx, dy),
    false => spec.d,
  };
  return "path($rule'$d')";
}
