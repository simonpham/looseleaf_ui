/// A point `(x, y)`.
///
/// Mirrors `Pt` in `src/lib/ink/types.ts`.
typedef Pt = (double, double);

/// Named access to a [Pt].
extension PtXY on Pt {
  /// The x coordinate.
  double get x => $1;

  /// The y coordinate.
  double get y => $2;
}

/// A mutable bounding box `[x0, y0, x1, y1]`.
///
/// Mirrors `BBox` in `src/lib/ink/types.ts`.
final class BBox {
  /// A box with the given corners.
  BBox(this.x0, this.y0, this.x1, this.y1);

  /// The empty box, `[∞, ∞, -∞, -∞]`, ready to [grow].
  BBox.empty()
    : x0 = double.infinity,
      y0 = double.infinity,
      x1 = double.negativeInfinity,
      y1 = double.negativeInfinity;

  /// Left.
  double x0;

  /// Top.
  double y0;

  /// Right.
  double x1;

  /// Bottom.
  double y1;

  /// Extends the box to hold `(x, y)`.
  void grow(double x, double y) {
    if (x < x0) x0 = x;
    if (x > x1) x1 = x;
    if (y < y0) y0 = y;
    if (y > y1) y1 = y;
  }

  /// Extends the box to hold [other].
  void growBox(BBox other) {
    if (other.x0 < x0) x0 = other.x0;
    if (other.y0 < y0) y0 = other.y0;
    if (other.x1 > x1) x1 = other.x1;
    if (other.y1 > y1) y1 = other.y1;
  }

  /// `[x0, y0, x1, y1]`.
  List<double> toList() => [x0, y0, x1, y1];
}

/// Output quality: `hi` keeps halos and hairs and a finer grid.
enum Tier { hi, lo }

/// The paint bucket an item is drawn in; buckets paint in declaration order.
enum Material { under, wash, hl, marker, pencil, waxy, text, felt, stamp, top }

/// A state layer of a drawing (`rest`, `hover`, …).
///
/// Mirrors `LayerName` in `src/lib/ink/types.ts` (and `InkLayerName`).
enum LayerName {
  rest,
  hover,
  pressed,
  focus,
  disabled,
  invalid,
  checked,
  indeterminate,
  open,
  busy,
}

/// The paper-grain mask a material is drawn through.
enum GrainKind { felt, marker, graphite, waxy, stamp }

/// The pen family.
enum PenKind { felt, pencil, marker, hl }

/// The pen weight class.
enum WeightClass { fine, std, brush }

/// The accent paints, each with an `m_` marker and an `f_` felt pen.
enum Accent { tomato, tangerine, lemon, grass, teal, sky, grape, bubblegum }

/// How a stroke starts.
enum StrokeStart { pool, soft }

/// How a stroke ends.
enum StrokeEnd { pool, flick, soft }

/// The part of a pen stroke a ribbon layer draws.
enum RibbonKind { halo, hair, body, core, pool, smear, rim, streak }
