import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// The width of the table rule tiles.
const double tableTileW = 960;

/// The height of the row rule tile.
const double tableRuleH = 8;

/// The height of the header rule tile.
const double tableHeadH = 12;

/// The width of a table cap tile.
const double tableCapW = 18;

/// CSS `url(...)` mask tiles for table rules: a pencil row rule, a double
/// header rule, and the rounded start and end caps.
///
/// Mirrors `TableTiles` in `src/lib/ink/recipes/table-ink.ts`.
final class TableTiles {
  /// Tiles.
  const TableTiles({
    required this.rule,
    required this.head,
    required this.capStart,
    required this.capEnd,
  });

  final String rule;
  final String head;
  final String capStart;
  final String capEnd;
}

typedef _Pull = ({double y, Pen pen, double? width, double? alpha});

final RegExp _paintAttr = RegExp(r'(fill|stroke)="var\(--ll-[a-z-]+\)"');

String _tileSvg(String seed, double w, double h, List<_Pull> pulls) {
  final ink = Ink(seed, tier: Tier.lo, grain: false);
  ink.layer(LayerName.rest, () {
    for (final p in pulls) {
      ink.stroke(
        [(-24, p.y), (w + 24, p.y)],
        p.pen,
        ruler.merge(StrokeOpts(width: p.width, alpha: p.alpha)),
      );
    }
  });
  final res = ink.toSvg(w: w, h: h, pad: 0);
  final body = res.svg.replaceAllMapped(_paintAttr, (m) => '${m[1]}="black"');
  final ws = JsMath.numberToString(w), hs = JsMath.numberToString(h);
  return "<svg xmlns='http://www.w3.org/2000/svg' width='$ws' height='$hs' "
      "viewBox='0 0 $ws $hs'>${body.replaceAll('"', "'")}</svg>";
}

/// [svg] as a CSS `url("data:…")`, escaping only what CSS needs.
///
/// Mirrors `svgUrl` in `src/lib/ink/recipes/table-ink.ts`.
String tableSvgUrl(String svg) {
  final enc = svg
      .replaceAll('%', '%25')
      .replaceAll('#', '%23')
      .replaceAll('<', '%3C')
      .replaceAll('>', '%3E')
      .replaceAll(RegExp(r'\s+'), ' ');
  return 'url("data:image/svg+xml,$enc")';
}

TableTiles? _cache;

/// The table's rule and cap tiles, drawn once.
///
/// Mirrors `tableTiles` in `src/lib/ink/recipes/table-ink.ts`.
TableTiles tableTiles() {
  if (_cache case final TableTiles cached) return cached;
  const w = tableTileW;
  final rule = _tileSvg('table-rule', w, tableRuleH, [
    (y: 4, pen: PenName.pencil.spec.copyWith(w: 1.3), width: null, alpha: null),
  ]);
  final head = _tileSvg('table-head', w, tableHeadH, [
    (
      y: 3.3,
      pen: PenName.ink.spec.copyWith(w: 2.3, halo: 0),
      width: null,
      alpha: null,
    ),
    (y: 8.5, pen: PenName.inkFine, width: null, alpha: null),
  ]);
  final tiles = TableTiles(
    rule: tableSvgUrl(rule),
    head: tableSvgUrl(head),
    capStart: tableSvgUrl(_capSvg(false)),
    capEnd: tableSvgUrl(_capSvg(true)),
  );
  _cache = tiles;
  return tiles;
}

String _capSvg(bool end) {
  const start = 'M18 0 L6 0 Q1 0 1 6 L1 34 Q1 40 6 40 L18 40 Z';
  const stop = 'M0 0 L12 0 Q17 0 17 6 L17 34 Q17 40 12 40 L0 40 Z';
  final d = switch (end) {
    true => stop,
    false => start,
  };
  return "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='40' "
      "viewBox='0 0 18 40' preserveAspectRatio='none'><path fill='black' "
      "d='$d'/></svg>";
}
