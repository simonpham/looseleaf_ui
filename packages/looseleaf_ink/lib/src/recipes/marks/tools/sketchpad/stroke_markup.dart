import 'dart:collection';
import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/marks/tools/tools.dart';

/// One stroke's markup, its centre line (for draw-on), length and bounds.
///
/// Mirrors `StrokeMarkup` in `src/lib/ink/recipes/sketchpad-ink.ts`.
final class StrokeMarkup {
  /// Stroke markup.
  const StrokeMarkup({
    required this.svg,
    required this.centre,
    required this.length,
    required this.bbox,
  });

  final String svg;

  /// Centre-line path data, at most ~64 points.
  final String centre;
  final double length;
  final StrokeBox bbox;
}

const int _cacheMax = 3000;
const int _cacheChars = 24000000;
final LinkedHashMap<String, StrokeMarkup> _cache = LinkedHashMap();
int _cacheCharsUsed = 0;

int _weigh(StrokeMarkup m) => m.svg.length + m.centre.length + 96;

/// The stroke cache's size and limits.
///
/// Mirrors `strokeCacheStats` in `src/lib/ink/recipes/sketchpad-ink.ts`.
({int entries, int chars, int maxChars, int maxEntries}) strokeCacheStats() => (
  entries: _cache.length,
  chars: _cacheCharsUsed,
  maxChars: _cacheChars,
  maxEntries: _cacheMax,
);

String _fingerprint(SketchStroke s) {
  var h = 0;
  for (final (x, y, p) in s.pts) {
    final sum =
        JsMath.imul(h, 31).toSigned(32) +
        JsMath.round(x * 10) * 7 +
        JsMath.round(y * 10) * 13 +
        JsMath.round((p ?? 0) * 10);
    h = JsMath.toUint32(sum).toSigned(32);
  }
  return '${s.id}|${s.tool.name}|${s.color.id}|'
      '${JsMath.numberToString(s.size)}|${s.pts.length}|$h';
}

/// The inked markup of [stroke] (LRU-cached unless [live]); [live] draws
/// the cheap, undried version shown while the pen is down.
///
/// Mirrors `strokeMarkup` in `src/lib/ink/recipes/sketchpad-ink.ts`.
StrokeMarkup strokeMarkup(
  SketchStroke stroke, {
  Tier? tier,
  bool live = false,
}) {
  final t = tier ?? Tier.lo;
  final liveKey = switch (live) {
    true => 1,
    false => 0,
  };
  final key = '${_fingerprint(stroke)}|${t.name}|$liveKey';
  if (_cache.remove(key) case final hit?) {
    _cache[key] = hit;
    return hit;
  }
  final (:pts, :pressure) = cleanPoints(stroke.pts);
  final (:pen, :color) = toolPen(stroke.tool, stroke.color);
  final ink = Ink('sk|${stroke.id}|${stroke.tool.name}', tier: t);
  final press = switch (pressure) {
    final List<double> pr when pts.length > 1 => pressFn(pts, pr),
    _ => null,
  };
  final brush = stroke.tool == DrawTool.brush;
  final opts = StrokeOpts(
    color: color,
    width: stroke.tool.base * stroke.size,
    wobble: switch (stroke.tool) {
      DrawTool.pencil => 0.2,
      _ => 0.12,
    },
    press: press,
    dry: switch ((live, brush)) {
      (true, _) => 0,
      (false, true) => 0.45,
      (false, false) => null,
    },
    simple: switch (live) {
      true => switch (stroke.tool) {
        DrawTool.felt || DrawTool.brush || DrawTool.pencil => true,
        _ => false,
      },
      false => null,
    },
    end: switch (live) {
      true => StrokeEnd.soft,
      false => null,
    },
  );
  ink.stroke(pts, pen, opts);
  final res = ink.toSvg(w: 1, h: 1, pad: 2);
  final step = math.max(1, (pts.length / 64).ceil());
  final centre = StringBuffer();
  var length = 0.0;
  for (var i = 0; i < pts.length; i += step) {
    final p = pts[i];
    if (i > 0) {
      length += JsMath.hypot(p.x - pts[i - step].x, p.y - pts[i - step].y);
    }
    final cmd = switch (i) {
      0 => 'M',
      _ => 'L',
    };
    centre.write('$cmd${n(p.x, 10)} ${n(p.y, 10)}');
  }
  if (pts.length > 1 && (pts.length - 1) % step != 0) {
    final last = pts[pts.length - 1];
    final from = pts[pts.length - 1 - ((pts.length - 1) % step)];
    length += JsMath.hypot(last.x - from.x, last.y - from.y);
    centre.write('L${n(last.x, 10)} ${n(last.y, 10)}');
  }
  final centreD = switch (pts) {
    [final only] => 'M${n(only.x, 10)} ${n(only.y, 10)}l.01 0',
    _ => centre.toString(),
  };
  final out = StrokeMarkup(
    svg: res.svg,
    centre: centreD,
    length: length,
    bbox: strokeBounds(stroke),
  );
  if (live) return out;
  final w = _weigh(out);
  if (w > _cacheChars) return out;
  while (_cache.isNotEmpty &&
      (_cache.length >= _cacheMax || _cacheCharsUsed + w > _cacheChars)) {
    final oldest = _cache.keys.first;
    if (_cache.remove(oldest) case final evicted?) {
      _cacheCharsUsed -= _weigh(evicted);
    }
  }
  _cache[key] = out;
  _cacheCharsUsed += w;
  return out;
}

/// Empties the stroke cache.
///
/// Mirrors `clearStrokeCache` in `src/lib/ink/recipes/sketchpad-ink.ts`.
void clearStrokeCache() {
  _cache.clear();
  _cacheCharsUsed = 0;
}

/// [svg] as a `data:` URL.
///
/// Mirrors `svgDataUrl` in `src/lib/ink/recipes/sketchpad-ink.ts`.
String svgDataUrl(String svg) =>
    'data:image/svg+xml;charset=utf-8,${Uri.encodeComponent(svg)}';

/// The crosshair cursor markup for [seed].
///
/// Mirrors `cursorMarkup` in `src/lib/ink/recipes/sketchpad-ink.ts`.
String cursorMarkup(String seed) {
  const o = StrokeOpts(wobble: 0, width: 0.8);
  final ink = Ink('sk-cursor|$seed')
    ..stroke([(-8, 0), (-2, 0)], PenName.focus, o)
    ..stroke([(2, 0), (8, 0)], PenName.focus, o)
    ..stroke([(0, -8), (0, -2)], PenName.focus, o)
    ..stroke([(0, 2), (0, 8)], PenName.focus, o);
  return ink.toSvg(w: 1, h: 1, pad: 2).svg;
}
