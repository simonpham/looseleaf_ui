import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// The drawing tools of the sketchpad, with their pen and base width.
///
/// Mirrors `DRAW_TOOLS` and `TOOL_PEN` in
/// `src/lib/ink/recipes/sketchpad-ink.ts`.
enum DrawTool {
  felt(PenName.ink, 1.5),
  brush(PenName.inkBrush, 1.05),
  pencil(PenName.pencil, 1.5),
  marker(PenName.terracotta, 0.85),
  highlighter(PenName.hi, 1);

  const DrawTool(this.pen, this.base);

  /// The pen the tool draws with.
  final PenName pen;

  /// Width multiplier of the tool.
  final double base;
}

/// Every sketchpad tool: the [DrawTool]s and the eraser.
///
/// Mirrors `SKETCH_TOOLS` in `src/lib/ink/recipes/sketchpad-ink.ts`.
enum SketchTool {
  felt(DrawTool.felt),
  brush(DrawTool.brush),
  pencil(DrawTool.pencil),
  marker(DrawTool.marker),
  highlighter(DrawTool.highlighter),
  eraser(null);

  const SketchTool(this.draw);

  /// The drawing tool, or null for the eraser.
  final DrawTool? draw;
}

/// The sketchpad palette; `id` is the upstream name.
///
/// Mirrors `SKETCH_COLORS` in `src/lib/ink/recipes/sketchpad-ink.ts`.
enum SketchColor {
  ink(PaintKey.ink),
  inkYou(PaintKey.inkYou),
  red(PaintKey.red),
  green(PaintKey.green),
  marker(PaintKey.marker),
  tangerine(PaintKey.tangerine),
  hi(PaintKey.hi),
  teal(PaintKey.teal),
  grape(PaintKey.grape),
  bubblegum(PaintKey.bubblegum);

  const SketchColor(this.paint);

  /// The paint token.
  final PaintKey paint;

  /// The upstream name.
  String get id => paint.id;

  /// Dark inks: the highlighter swaps them for its own yellow.
  ///
  /// Mirrors `DARK_INKS` in `src/lib/ink/recipes/sketchpad-ink.ts`.
  bool get dark => switch (this) {
    ink || inkYou || red || green => true,
    _ => false,
  };
}

/// Named stroke sizes and their width multipliers.
///
/// Mirrors `SKETCH_SIZES` in `src/lib/ink/recipes/sketchpad-ink.ts`.
enum SketchSizeName {
  fine(0.6, 2.2),
  medium(1, 4.4),
  bold(1.9, 7.4);

  const SketchSizeName(this.size, this.dotR);

  /// The width multiplier.
  final double size;

  /// The radius of the size picker's dot.
  final double dotR;
}

/// A captured point: x, y and pressure in `[0, 1]` (null when the device
/// gave none).
///
/// Mirrors `SketchPoint` in `src/lib/ink/recipes/sketchpad-ink.ts`.
typedef SketchPoint = (double, double, double?);

/// One stroke drawn on the sketchpad.
///
/// Mirrors `SketchStroke` in `src/lib/ink/recipes/sketchpad-ink.ts`.
final class SketchStroke {
  /// A stroke.
  const SketchStroke({
    required this.id,
    required this.tool,
    required this.color,
    required this.size,
    required this.pts,
  });

  final String id;
  final DrawTool tool;
  final SketchColor color;

  /// Width multiplier (see [SketchSizeName]).
  final double size;
  final List<SketchPoint> pts;
}

/// The pen and colour [tool] draws [color] with (the pencil only comes in
/// graphite and coloured orange-based leads).
///
/// Mirrors `toolPen` in `src/lib/ink/recipes/sketchpad-ink.ts`.
({PenName pen, PaintKey? color}) toolPen(DrawTool tool, SketchColor color) {
  if (tool == DrawTool.pencil && color == SketchColor.ink) {
    return (pen: tool.pen, color: null);
  }
  if (tool == DrawTool.pencil) return (pen: PenName.orange, color: color.paint);
  return (pen: tool.pen, color: color.paint);
}

/// The nominal width of a stroke of [tool] at [size].
///
/// Mirrors `strokeWidth` in `src/lib/ink/recipes/sketchpad-ink.ts`.
double strokeWidth(DrawTool tool, double size) =>
    tool.pen.spec.w * tool.base * size;
