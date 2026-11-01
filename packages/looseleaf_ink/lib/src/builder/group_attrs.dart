/// Attributes of a `<g>` drawn by `Ink.group`.
///
/// Mirrors `GroupAttrs` in `src/lib/ink/builder.ts`.
final class GroupAttrs {
  /// Group attributes.
  GroupAttrs({
    this.transform,
    this.clip,
    this.opacity,
    this.id,
    this.part,
    this.vars,
    this.hideOn,
    this.mask,
  });

  /// `transform`.
  String? transform;

  /// Clip path data; becomes a `<clipPath>` before the group.
  String? clip;

  /// `opacity`, written when below 1.
  double? opacity;

  /// `id`.
  String? id;

  /// `data-part`.
  String? part;

  /// CSS variables, written as `style="--k:v;…"`.
  Map<String, double>? vars;

  /// `data-hide-on`.
  String? hideOn;

  /// Mask id, written as `mask="url(#…)"`.
  String? mask;
}

/// How far a fill was laid off its outline, exposed as `--mx`/`--my`.
///
/// Mirrors `Offset` in `src/lib/ink/fills.ts`.
final class InkOffset {
  /// An offset.
  const InkOffset(this.dx, this.dy);

  /// No offset.
  static const InkOffset zero = InkOffset(0, 0);

  /// Horizontal.
  final double dx;

  /// Vertical.
  final double dy;
}
