import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/face_spec.dart';

/// One stacked piece of a faced sheet: SVG groups or a paper face.
sealed class SheetPiece {
  const SheetPiece();
}

/// Consecutive SVG markup, per layer, drawn in one `<svg>`.
final class SheetSvg extends SheetPiece {
  /// SVG groups.
  SheetSvg(this.groups);

  /// `(layer, markup)` pairs in paint order.
  final List<(LayerName, String)> groups;
}

/// A paper face, shown with [layer].
final class SheetFace extends SheetPiece {
  /// A face.
  const SheetFace(this.spec, this.layer);

  /// The face.
  final FaceSpec spec;

  /// The state layer it belongs to.
  final LayerName layer;
}

/// The paint stack of a faced frame: SVG runs and faces in order (always
/// ending with an SVG run), and the faces that cast shadows.
///
/// Mirrors `piecesOf` in `src/lib/ink/paper/sheet-layers.tsx`.
({List<SheetPiece> pieces, List<FaceSpec> casts}) sheetPieces(
  List<LayerName> layers,
  Map<LayerName, String> parts,
) {
  final out = <SheetPiece>[];
  final casts = <FaceSpec>[];
  SheetSvg? cur;
  for (final layer in layers) {
    for (final part in splitFaces(parts[layer] ?? '')) {
      switch (part) {
        case FaceMarkup(:final markup):
          final run = cur ?? SheetSvg([]);
          if (cur == null) out.add(run);
          cur = run;
          run.groups.add((layer, markup));
        case final FaceSpec spec when !spec.paper:
          casts.add(spec);
        case final FaceSpec spec:
          cur = null;
          casts.add(spec);
          out.add(SheetFace(spec, layer));
      }
    }
  }
  if (!out.any((p) => p is SheetSvg) || out.last is SheetFace) {
    out.add(SheetSvg([]));
  }
  return (
    pieces: out,
    casts: [
      for (final c in casts)
        if (c.cast != null) c,
    ],
  );
}
