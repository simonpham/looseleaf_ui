import 'dart:ui';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints sketch strokes from the engine's `strokeMarkup`.
///
/// Finished strokes come out of the engine's LRU as the same
/// [StrokeMarkup] object each time, so their parsed documents and centre
/// lines hang off that object and are parsed once; only the live stroke,
/// redrawn as the pen moves, is parsed per frame.
abstract final class SketchInk {
  static final Expando<InkDocument> _documents = Expando('ll-sketch-doc');
  static final Expando<Path> _centres = Expando('ll-sketch-centre');
  static final Map<String, InkDocument> _cursors = {};

  /// The engine tier [theme] draws at.
  static Tier tier(LooseleafThemeData theme) => switch (theme.effectiveTier) {
    LooseleafTier.lo => Tier.lo,
    LooseleafTier.hi => Tier.hi,
  };

  /// [markup] parsed, once per markup object.
  static InkDocument document(StrokeMarkup markup) =>
      _documents[markup] ??= InkDocument.parse(markup.svg);

  /// [markup]'s centre line as a path, for the replay's draw-on.
  static Path centre(StrokeMarkup markup) =>
      _centres[markup] ??= PathDataParser.parse(markup.centre);

  /// The keyboard cursor's crosshair for [seed].
  static InkDocument cursor(String seed) {
    if (_cursors.length > 32) _cursors.clear();
    return _cursors[seed] ??= InkDocument.parse(cursorMarkup(seed));
  }

  /// Paints every layer of [document] in [context].
  static void paint(
    Canvas canvas,
    InkDocument document,
    InkPaintContext context, {
    double opacity = 1,
  }) {
    final painter = InkPainter(document, context);
    for (final layer in document.layers.keys) {
      painter.paintLayer(canvas, layer, opacity: opacity);
    }
  }

  /// The width of [stroke]'s draw-on mask during a replay.
  ///
  /// Mirrors `strokeWidthOf` in upstream `src/components/ui/sketchpad.tsx`.
  static double replayMaskWidth(SketchStroke stroke) {
    final base = switch (stroke.tool) {
      DrawTool.highlighter => 14.0,
      DrawTool.marker => 8.0,
      _ => 3.4,
    };
    final width = base * stroke.size * 1.6 + 6;
    return switch (width < 8) {
      true => 8,
      false => width,
    };
  }
}
