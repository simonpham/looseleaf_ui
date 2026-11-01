/// Where a note sits on a corkboard: its top-left corner [x], [y] in
/// pixels from the cork's corner, its turn [r] in degrees and its stacking
/// depth [z]. Every field is optional: a missing one falls back to the
/// note's own props.
///
/// Mirrors `NotePosition` (as `Partial<NotePosition>`) in upstream
/// `src/components/ui/corkboard.tsx`.
class NotePosition {
  const NotePosition({this.x, this.y, this.r, this.z});

  final double? x;
  final double? y;

  /// The turn in degrees, clockwise.
  final double? r;

  /// The stacking depth; higher sits on top.
  final int? z;

  /// This position with [patch]'s fields laid over it.
  NotePosition merge(NotePosition patch) => NotePosition(
    x: patch.x ?? x,
    y: patch.y ?? y,
    r: patch.r ?? r,
    z: patch.z ?? z,
  );

  @override
  bool operator ==(Object other) =>
      other is NotePosition &&
      other.x == x &&
      other.y == y &&
      other.r == r &&
      other.z == z;

  @override
  int get hashCode => Object.hash(x, y, r, z);

  @override
  String toString() => 'NotePosition(x: $x, y: $y, r: $r, z: $z)';
}

/// A corkboard's layout: each note's [NotePosition] by note id.
typedef CorkboardValue = Map<String, NotePosition>;
