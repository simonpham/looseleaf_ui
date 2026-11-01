import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// Length of an [edgeTile].
const double edgeLen = 96;

/// Thickness of an [edgeTile].
const double edgeTh = 5;

/// Side of a [hatchTile].
const double hatchSize = 40;

/// Side of a [circleTile].
const double circleSize = 64;

const StrokeOpts _current = StrokeOpts(color: PaintKey.current);

String _tile(
  String seed,
  double w,
  double h,
  void Function(Ink ink) draw, [
  Tier tier = Tier.lo,
  bool stretch = false,
]) {
  final ink = Ink(seed, tier: tier, grain: false);
  ink.layer(LayerName.rest, () => draw(ink));
  final svg = ink.toSvg(w: w, h: h, pad: 0).svg;
  final fit = switch (stretch) {
    true => ' preserveAspectRatio="none"',
    false => '',
  };
  final ws = JsMath.numberToString(w), hs = JsMath.numberToString(h);
  final doc =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $ws $hs" '
      'width="$ws" height="$hs"$fit>$svg</svg>';
  return 'url("data:image/svg+xml,${Uri.encodeComponent(doc)}")';
}

/// A CSS `url(...)` of one ruled pencil edge, stretched along a border.
///
/// Mirrors `edgeTile` in `src/lib/ink/recipes/pencil-tiles-ink.ts`.
String edgeTile(String seed, bool vertical) {
  final w = switch (vertical) {
    true => edgeTh,
    false => edgeLen,
  };
  final h = switch (vertical) {
    true => edgeLen,
    false => edgeTh,
  };
  const c = edgeTh / 2;
  final List<Pt> ends = switch (vertical) {
    true => [(c, -16), (c, edgeLen + 16)],
    false => [(-16, c), (edgeLen + 16, c)],
  };
  return _tile(
    seed,
    w,
    h,
    (ink) => ink.stroke(
      ends,
      PenName.pencil,
      _current.merge(ruler).merge(const StrokeOpts(width: 0.95, simple: true)),
    ),
    Tier.lo,
    true,
  );
}

/// A CSS `url(...)` of a seamless pencil hatch tile.
///
/// Mirrors `hatchTile` in `src/lib/ink/recipes/pencil-tiles-ink.ts`.
String hatchTile(String seed) => _tile(seed, hatchSize, hatchSize, (ink) {
  final rng = ink.next('hatch');
  const gap = hatchSize / 5;
  final jitter = List.generate(5, (_) => rng.gauss(0, 0.35));
  final width = rng.range(0.86, 1.02);
  double slot(int i) => jitter[i % 5];
  final lines = <Line>[];
  for (var i = -4; i <= 9; i++) {
    final x0 = i * gap;
    final top = slot(i), bot = slot(i - 3);
    final slope = (bot - top) / hatchSize;
    final Pt a = (x0 + (hatchSize + 24) * 0.6 + top - slope * 24, -24);
    final Pt b = (x0 - 24 * 0.6 + bot + slope * 24, hatchSize + 24);
    lines.add(
      Line(
        [a, ((a.x + b.x) / 2, (a.y + b.y) / 2), b],
        o: StrokeOpts(
          simple: true,
          start: StrokeStart.soft,
          end: StrokeEnd.soft,
          speed: 1.1,
          wobble: 0.1,
          width: width,
        ),
      ),
    );
  }
  ink.lines(lines, PenName.pencil, _current);
}, Tier.hi);

/// A CSS `url(...)` of a pencil circle tile.
///
/// Mirrors `circleTile` in `src/lib/ink/recipes/pencil-tiles-ink.ts`.
String circleTile(String seed) => _tile(seed, circleSize, circleSize, (ink) {
  final lines = loopLines(
    ink.next('circle'),
    circleSize / 2,
    circleSize / 2,
    circleSize / 2 - 5,
    circleSize / 2 - 5,
    clean: true,
  );
  ink.lines(
    lines,
    PenName.pencil,
    _current.merge(const StrokeOpts(width: 1.05, simple: true)),
  );
});
