/// Horizontal text anchor.
enum LabelAnchor { start, middle, end }

/// Vertical text alignment.
enum LabelValign { top, middle, bottom }

/// What a label names.
enum LabelRole { x, y, cat, value, note, center, sub, ref, axis, legend }

/// A label's colour.
enum LabelTone { ink, muted, red, blue, green }

/// A text label placed by a chart layout.
///
/// Mirrors `ChartLabel` in `src/lib/ink/charts/chart-types.ts`.
final class ChartLabel {
  /// A label.
  const ChartLabel({
    required this.id,
    required this.text,
    required this.x,
    required this.y,
    required this.anchor,
    required this.valign,
    required this.role,
    this.tone,
    this.size,
    this.maxW,
    this.hidden,
  });

  /// A stable id, e.g. `x-3` or `note-0`.
  final String id;

  /// The text.
  final String text;

  /// Anchor x.
  final double x;

  /// Anchor y.
  final double y;

  /// Horizontal anchor.
  final LabelAnchor anchor;

  /// Vertical alignment.
  final LabelValign valign;

  /// What it names.
  final LabelRole role;

  /// Its colour.
  final LabelTone? tone;

  /// Font size in px.
  final double? size;

  /// The widest it may be.
  final double? maxW;

  /// Whether it is hidden.
  final bool? hidden;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'x': x,
    'y': y,
    'anchor': anchor.name,
    'valign': valign.name,
    'role': role.name,
    'tone': tone?.name,
    'size': size,
    'maxW': maxW,
    'hidden': hidden,
  };
}
