import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart' as pens;
import 'package:looseleaf_ink/src/pen/pen.dart'
    show Line, Pen, PenName, PenSpec, StrokeOpts, StrokeResult;

StrokeOpts _mergeOpts(StrokeOpts? a, StrokeOpts? b) {
  if (a == null) return b ?? const StrokeOpts();
  if (b == null) return a;
  return a
      .merge(b)
      .copyWith(
        width: (a.width ?? 1) * (b.width ?? 1),
        alpha: (a.alpha ?? 1) * (b.alpha ?? 1),
      );
}

/// Collects strokes, fills and raw markup into state layers and material
/// buckets, then emits SVG markup per layer.
///
/// Every random choice forks from the seed by name and call count
/// ([next]), so the same seed and the same calls give the same markup.
///
/// Mirrors `Ink` in `src/lib/ink/builder.ts`.
final class Ink {
  /// A drawing seeded by [seed] (string or number).
  Ink(Object seed, {Tier? tier, bool? grain, bool? calm, Knobs? knobs})
    : rng = Rng(seed) {
    this.calm = calm ?? false;
    this.tier = switch (this.calm) {
      true => Tier.lo,
      false => tier ?? Tier.lo,
    };
    this.grain = grain ?? true;
    this.knobs = (knobs ?? Knobs()).copyWith();
    if (this.calm) {
      this.knobs
        ..wobble *= 0.3
        ..misreg = 0
        ..width *= 0.85;
    }
    _cur = _rootOf(LayerName.rest);
  }

  /// The root stream.
  final Rng rng;

  /// The hashed seed.
  int get seed => rng.seed;

  late final Tier tier;
  late final bool grain;
  late final bool calm;
  late final Knobs knobs;

  /// The grain phase variant, `seed % 6`.
  int get variant => seed % maskVariants;

  String get _tag => seed.toRadixString(36);

  int _count = 0;
  int _defCount = 0;
  final Map<LayerName, Scope> _roots = {};
  bool _leaned = false;
  late Scope _cur;
  final BBox _bb = BBox.empty();

  /// Merges subtle grain runs into one mask when emitting, and keeps felt
  /// halos in the felt bucket.
  void lean() => _leaned = true;

  Scope _rootOf(LayerName name) => _roots.putIfAbsent(name, Scope.new);

  /// A fresh stream for one drawing call, forked as `name:count`.
  Rng next(String name) => rng.fork('$name:${_count++}');

  /// Grows the drawing bounds.
  void grow(BBox bb) => _bb.growBox(bb);

  /// Draws [fn] into the [name] layer.
  void layer(LayerName name, void Function() fn) {
    final prev = _cur;
    _cur = _rootOf(name);
    try {
      fn();
    } finally {
      _cur = prev;
    }
  }

  /// Draws [fn] into a `<g>` with [attrs], placed in the [at] bucket.
  void group(
    GroupAttrs attrs,
    void Function() fn, [
    Material at = Material.top,
  ]) {
    final scope = Scope(attrs);
    _cur.add(at, ScopeItem(scope));
    final prev = _cur;
    _cur = scope;
    try {
      fn();
    } finally {
      _cur = prev;
    }
  }

  /// Draws [fn] into a `data-part` group; when [fn] returns an [InkOffset]
  /// (a fill), it is exposed as `--mx`/`--my`. [fn] may return anything else
  /// (upstream: `() => Offset | void`).
  void part(String name, dynamic Function() fn, [Material at = Material.wash]) {
    final attrs = GroupAttrs(part: name);
    group(attrs, () {
      if (fn() case final InkOffset off) {
        attrs.vars = {'mx': off.dx, 'my': off.dy};
      }
    }, at);
  }

  /// Adds a `<clipPath>` for [d] and returns its id.
  String clipDef(String d) {
    final id = 'll-c${hashSeed(d).toRadixString(36)}';
    _cur.add(
      Material.under,
      RawItem('<clipPath id="$id"><path d="$d"/></clipPath>'),
    );
    return id;
  }

  /// Draws [fn] into a `<defs>` group and returns its id, for [use].
  String define(void Function() fn) {
    final id = 'll-$_tag-${_defCount++}';
    final scope = Scope();
    final prev = _cur;
    _cur = scope;
    try {
      fn();
    } finally {
      _cur = prev;
    }
    _cur.add(
      Material.under,
      RawItem('<defs><g id="$id">${_emitter.emit(scope)}</g></defs>'),
    );
    return id;
  }

  /// Adds a `<use>` of a [define]d group.
  void use(
    String id, {
    double? x,
    double? y,
    String? transform,
    Material at = Material.top,
  }) {
    final xs = switch (x) {
      final double v when v != 0 && !v.isNaN => ' x="${n(v)}"',
      _ => '',
    };
    final ys = switch (y) {
      final double v when v != 0 && !v.isNaN => ' y="${n(v)}"',
      _ => '',
    };
    final tf = switch (transform) {
      final String t when t.isNotEmpty => ' transform="$t"',
      _ => '',
    };
    _cur.add(at, RawItem('<use href="#$id"$xs$ys$tf/>'));
  }

  /// Strokes [pts] with [pen], applying the knobs and a little per-stroke
  /// width (and, on `hi`, alpha) jitter.
  StrokeResult stroke(
    List<Pt> pts, [
    Pen pen = PenName.ink,
    StrokeOpts o = const StrokeOpts(),
  ]) {
    var p = pen.spec;
    if (knobs.bleed != 1) p = p.copyWith(bleed: p.bleed * knobs.bleed);
    final r = next('s');
    final jr = r.fork('jit');
    final width = (o.width ?? 1) * knobs.width * (1 + jr.gauss(0, 0.05));
    final alphaJitter = switch (tier) {
      Tier.hi => math.min(1.08, math.max(0.92, 1 + jr.gauss(0, 0.04))),
      Tier.lo => 1.0,
    };
    final alpha = (o.alpha ?? 1) * alphaJitter;
    final res = pens.stroke(
      pts,
      p,
      r,
      o.copyWith(
        tier: tier,
        wobble: (o.wobble ?? 1) * knobs.wobble,
        width: width,
        alpha: alpha,
      ),
    );
    return _put(res, p);
  }

  /// Strokes each line, its own options merged over [o] (widths and alphas
  /// multiply).
  void lines(List<Line> lines, [Pen pen = PenName.ink, StrokeOpts? o]) {
    for (final l in lines) {
      stroke(l.pts, l.pen ?? pen, _mergeOpts(l.o, o));
    }
  }

  /// A blot of ink.
  void dot(
    double cx,
    double cy,
    double r, [
    Pen pen = PenName.ink,
    StrokeOpts o = const StrokeOpts(),
  ]) {
    final p = pen.spec;
    final res = pens.dot(
      cx,
      cy,
      r,
      p,
      next('d'),
      o.copyWith(tier: tier, width: (o.width ?? 1) * knobs.width),
    );
    _put(res, p);
  }

  StrokeResult _put(StrokeResult res, PenSpec p) {
    for (final layer in res.layers) {
      final item = PathItem(
        d: layer.d,
        fill: layer.fill,
        op: layer.op,
        evenOdd: layer.evenOdd,
      );
      _cur.add(_materialOf(p, layer.k), item);
    }
    grow(res.bbox);
    return res;
  }

  Material _materialOf(PenSpec p, RibbonKind k) {
    final washed = (k == RibbonKind.halo || k == RibbonKind.hair) && !_leaned;
    return switch (p.kind) {
      PenKind.felt when washed => Material.wash,
      PenKind.felt => Material.felt,
      PenKind.pencil when p.waxy => Material.waxy,
      PenKind.pencil => Material.pencil,
      PenKind.marker => Material.marker,
      PenKind.hl => Material.hl,
    };
  }

  /// Adds a ready-made path to the [material] bucket.
  void flat(
    Material material,
    String d,
    PaintKey fill, {
    double op = 1,
    bool evenOdd = false,
    PaintKey? stroke,
    double? sw,
    BBox? bbox,
    String? clip,
  }) {
    if (d.isEmpty) return;
    _cur.add(
      material,
      PathItem(
        d: d,
        fill: fill,
        op: op,
        evenOdd: evenOdd,
        stroke: stroke,
        sw: sw,
        clip: clip,
      ),
    );
    if (bbox != null) grow(bbox);
  }

  /// Fills the smooth outline of [pts].
  void poly(Material material, List<Pt> pts, PaintKey fill, [double op = 1]) {
    if (pts.length < 3) return;
    flat(
      material,
      smoothClosed(pts, tierCfg(tier)),
      fill,
      op: op,
      bbox: bboxOf(pts),
    );
  }

  /// Adds raw markup to the [material] bucket.
  void raw(String svg, [Material material = Material.text]) {
    if (svg.isNotEmpty) _cur.add(material, RawItem(svg));
  }

  /// Adds a `<text>`.
  void text(
    double x,
    double y,
    String s, {
    double size = 16,
    PaintKey fill = PaintKey.ink,
    String? font,
    String? anchor,
    num? weight,
  }) {
    final anchorAttr = switch (anchor) {
      final String a when a.isNotEmpty => ' text-anchor="$a"',
      _ => '',
    };
    final weightAttr = switch (weight) {
      final num w when w != 0 && !w.isNaN =>
        ' font-weight="${JsMath.numberToString(w)}"',
      _ => '',
    };
    final attrs =
        'x="${n(x)}" y="${n(y)}" font-size="${n(size)}" fill="${paint(fill)}" '
        'font-family="${esc(font ?? 'var(--font-hand, cursive)')}"$anchorAttr$weightAttr';
    raw('<text $attrs>${esc(s)}</text>', Material.text);
  }

  InkEmitter get _emitter =>
      InkEmitter(tier: tier, grain: grain, leaned: _leaned, variant: variant);

  /// Emits the markup of every layer (or only [layers]).
  InkResult toSvg({
    required double w,
    required double h,
    double? pad,
    List<LayerName>? layers,
  }) {
    final names = [
      for (final k in _roots.keys)
        if (layers == null || layers.contains(k)) k,
    ];
    final emitter = _emitter;
    final parts = <LayerName, String>{
      for (final name in names) name: emitter.emit(_roots[name] ?? Scope()),
    };
    double fin(double v) => switch (v.isFinite) {
      true => v,
      false => 0,
    };
    final bbox = BBox(fin(_bb.x0), fin(_bb.y0), fin(_bb.x1), fin(_bb.y1));
    final excursion = [
      0.0,
      -bbox.x0,
      -bbox.y0,
      bbox.x1 - w,
      bbox.y1 - h,
    ].reduce(math.max);
    final padding = pad ?? math.max(2, excursion.ceil() + 1).toDouble();
    final svg = switch (names) {
      [final only] => parts[only] ?? '',
      _ => names.map((k) => '<g data-layer="${k.name}">${parts[k]}</g>').join(),
    };
    return InkResult(
      svg: svg,
      w: w,
      h: h,
      pad: padding,
      layers: names,
      parts: parts,
      bbox: bbox,
    );
  }
}
