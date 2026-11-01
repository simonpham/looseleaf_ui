import 'dart:ui';

import 'package:looseleaf_ui/src/frame/ink_sheet.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';

/// A drawn, parsed frame: its layers in paint order and the documents that
/// hold them. Eager layers share one document; each lazy layer, drawn later
/// by its own ink run, has its own.
class InkFrame {
  const InkFrame({
    required this.key,
    required this.width,
    required this.height,
    required this.pad,
    required this.layers,
    required this.documents,
    this.sheet,
  });

  final String key;

  /// The bucketed box the frame was drawn for (the viewBox minus [pad]).
  final double width;
  final double height;
  final double pad;

  /// Layer names in paint order.
  final List<String> layers;

  /// Layer name to the document holding it.
  final Map<String, InkDocument> documents;

  /// The paint stack when the frame holds paper faces; its layers then
  /// paint through [InkSheet.document] instead of [documents].
  final InkSheet? sheet;

  bool has(String layer) => documents.containsKey(layer);

  /// Whether any layer blends, so the frame must be painted isolated.
  bool get usesBlend => documents.values.any((document) => document.usesBlend);

  /// The bounds of [layer] in user units, or null when unknown.
  Rect? boundsOf(String layer) => documents[layer]?.layers[layer]?.bounds;
}
