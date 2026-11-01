import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/fields/fields.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Height of the weekday header row.
const double calendarHead = 28;

/// Side of a day cell, and of the day tiles.
const double calendarCell = 40;

/// How many hand-drawn variants of the selection ring and wash exist.
const int ringHands = 4;

/// How many hand-drawn variants of the today underline exist.
const int underlineHands = 3;

/// How many range band frames exist (alternating by row).
const int bandFrames = 2;

/// Side of a [focusTile].
const double focusTileSize = calendarCell + 16;

const double _bandH = 28;
const double _cap = 6.4;
const StrokeOpts _current = StrokeOpts(color: PaintKey.current);

String _tile(String seed, double w, double h, void Function(Ink ink) draw) {
  final ink = Ink(seed, tier: Tier.lo, grain: false);
  ink.layer(LayerName.rest, () => draw(ink));
  final svg = ink.toSvg(w: w, h: h, pad: 0).svg;
  final ws = JsMath.numberToString(w), hs = JsMath.numberToString(h);
  final doc =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $ws $hs" '
      'width="$ws" height="$hs">$svg</svg>';
  return 'url("data:image/svg+xml,${Uri.encodeComponent(doc)}")';
}

/// A CSS `url(...)` of a hand-drawn ring around a selected day.
///
/// Mirrors `ringTile` in `src/lib/ink/recipes/calendar-ink.ts`.
String ringTile(String seed) => _tile(seed, calendarCell, calendarCell, (ink) {
  final rng = ink.next('ring');
  final lines = loopLines(
    rng,
    calendarCell / 2 + rng.range(-0.6, 0.6),
    calendarCell / 2 + rng.range(-0.6, 0.6),
    16.3 + rng.range(-0.6, 0.4),
    16 + rng.range(-0.5, 0.5),
    loose: 1.5,
    breathe: 0.05,
  );
  ink.lines(
    lines,
    PenName.inkBrush,
    _current.merge(const StrokeOpts(width: 0.86, simple: true)),
  );
});

/// A CSS `url(...)` of the marker wash under a selected day.
///
/// Mirrors `washTile` in `src/lib/ink/recipes/calendar-ink.ts`.
String washTile(String seed) => _tile(seed, calendarCell, calendarCell, (ink) {
  blobFill(
    ink,
    ellipsePoly(calendarCell / 2 + 0.8, calendarCell / 2 + 1, 15.2, 15.6, 26),
    PaintKey.current,
    alpha: 1,
    rough: 0.9,
  );
});

/// A CSS `url(...)` of today's underline, single or [double].
///
/// Mirrors `underlineTile` in `src/lib/ink/recipes/calendar-ink.ts`.
String underlineTile(String seed, bool double) =>
    _tile(seed, calendarCell, 10, (ink) {
      final lines = underlineLines(
        ink.next('ul'),
        3,
        5.6,
        calendarCell - 7,
        kind: switch (double) {
          true => UnderlineKind.double,
          false => UnderlineKind.single,
        },
      );
      ink.lines(
        lines,
        PenName.inkBrush,
        _current.merge(const StrokeOpts(width: 0.8, simple: true)),
      );
    });

/// A CSS `url(...)` of the focus ring around a day.
///
/// Mirrors `focusTile` in `src/lib/ink/recipes/calendar-ink.ts`.
String focusTile(String seed) =>
    _tile(seed, focusTileSize, focusTileSize, (ink) {
      focusRing(
        ink,
        12,
        12,
        calendarCell - 8,
        calendarCell - 8,
        shape: FocusShape.ellipse,
        gap: 3,
        pen: PenName.inkBrush,
        opts: _current.merge(const StrokeOpts(width: 0.7, simple: true)),
      );
    });

({double Function(double x) top, double Function(double x) bot}) _edges(
  String seed,
) {
  final rng = Ink(seed, grain: false).next('band');
  final a1 = rng.range(0.55, 0.95),
      a2 = rng.range(0.2, 0.45),
      b1 = rng.range(0.55, 0.95),
      b2 = rng.range(0.2, 0.45);
  final p1 = rng.range(0, tau),
      p2 = rng.range(0, tau),
      p3 = rng.range(0, tau),
      p4 = rng.range(0, tau);
  double per(double x, double k, double p) =>
      JsMath.sin((tau * k * x) / calendarCell + p);
  return (
    top: (x) => 1.3 + a1 * per(x, 1, p1) + a2 * per(x, 2, p2),
    bot: (x) => _bandH - 1.3 + b1 * per(x, 1, p3) + b2 * per(x, 2, p4),
  );
}

/// A CSS `url(...)` of one cell of a selected range band, capped at the
/// [left] and/or [right] end.
///
/// Mirrors `bandTile` in `src/lib/ink/recipes/calendar-ink.ts`.
String bandTile(String seed, bool left, bool right) {
  final (:top, :bot) = _edges(seed);
  final caps =
      '${switch (left) {
        true => 'l',
        false => '',
      }}${switch (right) {
        true => 'r',
        false => '',
      }}';
  return _tile('$seed|$caps', calendarCell, _bandH, (ink) {
    final rng = ink.next('caps');
    final slantL = rng.range(-1.6, 1.6), slantR = rng.range(-1.6, 1.6);
    final xa = switch (left) {
      true => 1.8 + _cap,
      false => -8.0,
    };
    final xb = switch (right) {
      true => calendarCell - 1.8 - _cap,
      false => calendarCell + 8,
    };
    double bulge(double t, double slant) {
      final u = (t - 0.5) * 2;
      return _cap * math.sqrt(1 - JsMath.pow(u.abs(), 2.6)) + slant * u;
    }

    final pts = <Pt>[];
    for (var x = xa; x <= xb + 0.01; x += 2) {
      pts.add((x, top(x)));
    }
    if (right) {
      for (var i = 1; i <= 9; i++) {
        pts.add((
          xb + bulge(i / 10, slantR),
          top(xb) + (bot(xb) - top(xb)) * (i / 10),
        ));
      }
    }
    for (var x = xb; x >= xa - 0.01; x -= 2) {
      pts.add((x, bot(x)));
    }
    if (left) {
      for (var i = 9; i >= 1; i--) {
        pts.add((
          xa - bulge(i / 10, slantL),
          top(xa) + (bot(xa) - top(xa)) * (i / 10),
        ));
      }
    }
    ink.poly(Material.marker, pts, PaintKey.current);
  });
}

/// Calendar grid params.
///
/// Mirrors `CalendarGridParams` in `src/lib/ink/recipes/calendar-ink.ts`.
final class CalendarGridParams {
  /// Params.
  const CalendarGridParams({required this.rows, this.weekNumbers = false});

  /// Week rows below the header.
  final int rows;

  /// Leaves a red-ruled margin column for week numbers.
  final bool weekNumbers;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'rows': rows,
    if (weekNumbers) 'weekNumbers': true,
  };
}

/// The month grid: an inked header rule, pencil row and column rules, and a
/// red margin before the week numbers.
///
/// Mirrors `calendarGridRecipe` in `src/lib/ink/recipes/calendar-ink.ts`.
final Recipe<CalendarGridParams> calendarGridRecipe =
    defineRecipe<CalendarGridParams>(
      id: 'calendar-grid',
      kind: 'calendar',
      layers: const [LayerName.rest],
      pad: 12,
      draw: _drawGrid,
    );

void _drawGrid(
  Ink ink,
  Box size,
  CalendarGridParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final rows = params.rows;
  final weekNumbers = params.weekNumbers;
  final head = math.min(calendarHead, h * 0.4);
  final cell = (h - head) / math.max(1, rows);
  final wn = switch (weekNumbers) {
    true => math.max(0.0, w - 7 * cell),
    false => 0.0,
  };
  final rtl = ctx.dir == Dir.rtl;
  double x(double v) => switch (rtl) {
    true => w - v,
    false => v,
  };
  final calm = ctx.calm;
  ink.layer(LayerName.rest, () {
    line(
      ink,
      -2,
      head,
      w + 3,
      head,
      pen: switch (calm) {
        true => PenName.pencilFine,
        false => PenName.inkFine,
      },
      opts: const StrokeOpts(alpha: 0.85, simple: true),
    );
    for (var r = 1; r <= rows; r++) {
      final y = head + r * cell;
      line(
        ink,
        -2,
        y,
        w + 3,
        y,
        pen: switch (calm) {
          true => PenName.pencilFine,
          false => PenName.pencil,
        },
        opts: StrokeOpts(
          alpha: switch (calm) {
            true => 0.7,
            false => 0.75,
          },
          simple: true,
        ),
      );
    }
    for (var c = 0; c <= 7; c++) {
      final cx = x(wn + c * cell);
      final margin = weekNumbers && c == 0;
      final edge = c == 0 || c == 7;
      line(
        ink,
        cx,
        switch (margin) {
          true => -1,
          false => head,
        },
        cx,
        h +
            switch (margin) {
              true => 3,
              false => 2,
            },
        pen: switch (margin) {
          true => PenName.redFine,
          false => PenName.pencilFine,
        },
        opts: StrokeOpts(
          alpha: switch ((margin, edge)) {
            (true, _) => 0.85,
            (false, true) => 0.6,
            (false, false) => 0.42,
          },
          simple: true,
        ),
      );
    }
  });
}

/// Calendar month/year dropdown params.
///
/// Mirrors `CalendarDropdownParams` in `src/lib/ink/recipes/calendar-ink.ts`.
final class CalendarDropdownParams {
  /// Params.
  const CalendarDropdownParams({this.disabled = false});

  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {if (disabled) 'disabled': true};
}

/// The caption's month and year dropdowns: a [drawFieldFrame].
///
/// Mirrors `calendarDropdownRecipe` in `src/lib/ink/recipes/calendar-ink.ts`.
final Recipe<CalendarDropdownParams> calendarDropdownRecipe =
    defineRecipe<CalendarDropdownParams>(
      id: 'calendar-dropdown',
      kind: 'field',
      layers: const [
        LayerName.rest,
        LayerName.hover,
        LayerName.focus,
        LayerName.disabled,
        LayerName.invalid,
      ],
      lazy: const [LayerName.focus, LayerName.hover],
      pad: 12,
      draw: (ink, size, params, ctx) => drawFieldFrame(
        ink,
        size,
        FieldFrameParams(disabled: params.disabled),
        ctx,
      ),
    );
