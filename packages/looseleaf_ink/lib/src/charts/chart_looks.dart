import 'package:looseleaf_ink/src/core/core.dart';

/// The paint of each series slot, in order (`SLOT_KEYS`).
///
/// Mirrors `SLOT_KEYS` in `src/lib/ink/charts/chart-types.ts`.
const List<PaintKey> slotKeys = [
  PaintKey.marker,
  PaintKey.inkYou,
  PaintKey.green,
  PaintKey.hiDeep,
  PaintKey.grape,
  PaintKey.red,
  PaintKey.pencil,
  PaintKey.orangeText,
];

/// How many slot paints there are (`SLOT_COUNT`).
const int slotCount = 8;

int _wrap(int v, int n) => ((v % n) + n) % n;

/// The paint of series [slot], wrapping around.
///
/// Mirrors `slotKey` in `src/lib/ink/charts/chart-types.ts`.
PaintKey slotKey(int slot) => slotKeys[_wrap(slot, slotCount)];

/// A fill pattern for bars, slices and areas.
///
/// Mirrors `Pattern` in `src/lib/ink/charts/chart-types.ts`.
enum FillPattern { solid, hatch, dots, cross, lines, scribble }

/// A point marker.
///
/// Mirrors `MarkerShape` in `src/lib/ink/charts/chart-types.ts`.
enum MarkerShape { circle, square, triangle, diamond, cross, plus, none }

/// The markers series cycle through (`MARKERS`, without `none`).
const List<MarkerShape> markers = [
  MarkerShape.circle,
  MarkerShape.square,
  MarkerShape.triangle,
  MarkerShape.diamond,
  MarkerShape.cross,
  MarkerShape.plus,
];

/// A line dash.
///
/// Mirrors `Dash` in `src/lib/ink/charts/chart-types.ts`.
enum Dash { solid, dashed, dotted, dashdot }

/// The pattern series [slot] gets by default.
///
/// Mirrors `defaultPattern` in `src/lib/ink/charts/chart-types.ts`.
FillPattern defaultPattern(int slot) =>
    FillPattern.values[_wrap(slot, FillPattern.values.length)];

/// The marker series [slot] gets by default.
///
/// Mirrors `defaultMarker` in `src/lib/ink/charts/chart-types.ts`.
MarkerShape defaultMarker(int slot) => markers[_wrap(slot, markers.length)];

/// The dash series [slot] gets by default.
///
/// Mirrors `defaultDash` in `src/lib/ink/charts/chart-types.ts`.
Dash defaultDash(int slot) => Dash.values[_wrap(slot, Dash.values.length)];

/// The pen an annotation is written with.
///
/// Mirrors `NotePen` in `src/lib/ink/charts/chart-types.ts`.
enum NotePen { red, blue, ink, green }

/// Whether a chart has data, none, or is loading.
enum ChartState { ready, empty, loading }
