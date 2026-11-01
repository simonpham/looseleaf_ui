import 'dart:ui';

import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
import 'package:looseleaf_ui/src/painter/painter.dart';

/// One piece of a faced frame's paint stack: ink or a paper face.
sealed class InkSheetPiece {
  const InkSheetPiece();
}

/// A run of ink between faces: `(layer, part)` pairs, where `part` names the
/// group of [InkSheet.document] holding that layer's share of the run.
final class InkSheetRun extends InkSheetPiece {
  const InkSheetRun(this.groups);

  /// `(state layer, document part)` pairs in paint order.
  final List<(String, String)> groups;
}

/// A paper face, shown with its state [layer].
final class InkSheetFace extends InkSheetPiece {
  InkSheetFace(this.spec, this.layer)
    : path = PathDataParser.parse(spec.d)
        ..fillType = switch (spec.evenodd) {
          true => PathFillType.evenOdd,
          false => PathFillType.nonZero,
        };

  /// The face.
  final ink.FaceSpec spec;

  /// The state layer it belongs to.
  final String layer;

  /// [spec]'s clip path, parsed once.
  final Path path;
}

/// A frame whose markup holds paper faces (`<!--ll-face:…-->`): the paint
/// stack of ink runs and faces in order, the faces that cast shadows, and
/// one document holding every run, so ids resolve across runs as they do
/// across upstream's sibling `<svg>`s.
///
/// Mirrors `piecesOf` and `SheetLayers` in
/// `src/lib/ink/paper/sheet-layers.tsx`.
final class InkSheet {
  const InkSheet({
    required this.pieces,
    required this.casts,
    required this.document,
  });

  /// Splits [parts] (layer to markup, painted in [layers] order) into runs and
  /// faces; null when no part holds a face.
  static InkSheet? of(List<String> layers, Map<String, String> parts) {
    if (!parts.values.any(ink.hasFace)) return null;
    final names = {for (final layer in ink.LayerName.values) layer.name: layer};
    final known = [for (final layer in layers) ?names[layer]];
    final split = ink.sheetPieces(known, {
      for (final layer in known) layer: parts[layer.name] ?? '',
    });
    final markup = <String, String>{};
    final pieces = <InkSheetPiece>[];
    for (final (index, piece) in split.pieces.indexed) {
      switch (piece) {
        case ink.SheetFace(:final spec, :final layer):
          pieces.add(InkSheetFace(spec, layer.name));
        case ink.SheetSvg(:final groups):
          final run = <(String, String)>[];
          for (final (layer, part) in groups) {
            final key = '${layer.name}#$index';
            markup[key] = part;
            run.add((layer.name, key));
          }
          pieces.add(InkSheetRun(run));
      }
    }
    return InkSheet(
      pieces: pieces,
      casts: split.casts,
      document: InkDocument.parseLayers(markup),
    );
  }

  /// Ink runs and faces in paint order.
  final List<InkSheetPiece> pieces;

  /// The faces that cast a shadow, painted under everything.
  final List<ink.FaceSpec> casts;

  /// Every run's markup, one group per `(layer, run)`.
  final InkDocument document;
}
