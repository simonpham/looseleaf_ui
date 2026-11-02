import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

const PenSpec _base = PenSpec(
  kind: PenKind.felt,
  color: PaintKey.ink,
  grain: GrainKind.felt,
  cls: WeightClass.std,
  w: 1.7,
  alpha: 0.92,
  wob: Wobble(amp: 0.8, wl: 80, tr: 0.16),
  step: 1.8,
  halo: 0,
  bleed: 1,
  core: 0.3,
  pool: 1,
  feather: 0,
  skip: 0,
  swell: 0.4,
  dir: 0,
  dryAmt: 0,
  dryWl: 7,
  gaps: 0,
  dens: 0.5,
  taper: 1,
  smear: 0,
  waxy: false,
  nib: 0,
  edge: 0.2,
  wet: 0.2,
  cutK: 0.22,
);

PenSpec _felt(PaintKey color) => _base.copyWith(
  kind: PenKind.felt,
  grain: GrainKind.felt,
  color: color,
  halo: 0.14,
  bleed: 1.05,
  core: 0.36,
  pool: 1,
  feather: 0.5,
  skip: 0.3,
  swell: 0.4,
  dir: 0.06,
  dens: 0.5,
);

PenSpec _pencil(PaintKey color, {bool waxy = false}) => _base.copyWith(
  kind: PenKind.pencil,
  grain: switch (waxy) {
    true => GrainKind.waxy,
    false => GrainKind.graphite,
  },
  color: color,
  w: 1.5,
  alpha: 0.95,
  wob: const Wobble(amp: 0.6, wl: 110, tr: 0.12),
  step: 1.3,
  smear: 0.22,
  dens: 0.5,
  waxy: waxy,
);

PenSpec _marker(PaintKey color) => _base.copyWith(
  kind: PenKind.marker,
  grain: GrainKind.marker,
  color: color,
  w: 9,
  alpha: 0.62,
  nib: -0.75,
  edge: 0.3,
  wet: 0.22,
  bleed: 1,
  wob: const Wobble(amp: 0.9, wl: 90, tr: 0.1),
  step: 2.2,
  cutK: 0.22,
);

PenSpec _withClass(PenSpec p, WeightClass cls) {
  final fine = cls == WeightClass.fine;
  if (p.kind == PenKind.felt && fine) {
    return p.copyWith(
      cls: cls,
      w: p.w * 0.68,
      alpha: math.min(0.96, p.alpha + 0.02),
      wob: Wobble(amp: p.wob.amp * 0.7, wl: p.wob.wl * 1.2, tr: p.wob.tr * 0.6),
      step: 1.6,
      halo: p.halo * 0.55,
      bleed: p.bleed * 0.6,
      core: p.core * 0.8,
      pool: p.pool * 0.7,
      feather: p.feather * 0.4,
      skip: p.skip * 0.4,
      swell: 0.18,
      dir: 0,
      dens: 0.3,
    );
  }
  if (p.kind == PenKind.felt) {
    return p.copyWith(
      cls: cls,
      w: p.w * 2,
      alpha: p.alpha - 0.02,
      wob: Wobble(
        amp: p.wob.amp * 1.1,
        wl: p.wob.wl * 1.1,
        tr: p.wob.tr * 0.75,
      ),
      step: 2.2,
      halo: p.halo * 0.85,
      bleed: p.bleed * 1.2,
      core: p.core * 1.1,
      pool: p.pool * 1.15,
      feather: p.feather * 1.1,
      skip: 0.15,
      swell: 0.8,
      dir: 0.38,
      dryAmt: 0.55,
      dryWl: 7,
      gaps: 0.5,
      dens: 0.8,
      taper: 1.6,
    );
  }
  if (fine) {
    return p.copyWith(
      cls: cls,
      w: p.w * 0.68,
      alpha: p.alpha * 0.92,
      smear: p.smear * 0.8,
      wob: p.wob.copyWith(amp: p.wob.amp * 0.8),
      step: 1.1,
    );
  }
  return p.copyWith(
    cls: cls,
    w: p.w * 1.9,
    alpha: p.alpha * 0.88,
    smear: p.smear * 1.4,
    dir: 0.14,
    dryAmt: 0.25,
    step: 1.6,
  );
}

final Map<String, PenSpec> _basePens = {
  'ink': _felt(PaintKey.ink),
  'blue': _felt(PaintKey.inkYou).copyWith(
    w: 1.85,
    alpha: 0.9,
    wob: const Wobble(amp: 0.9, wl: 70, tr: 0.18),
    halo: 0.16,
    bleed: 1.2,
    core: 0.32,
    pool: 1.1,
    feather: 0.6,
    skip: 0.25,
  ),
  'redfelt': _felt(
    PaintKey.red,
  ).copyWith(w: 1.75, alpha: 0.9, halo: 0.14, bleed: 1, core: 0.32),
  'greenfelt': _felt(
    PaintKey.green,
  ).copyWith(w: 1.75, alpha: 0.9, halo: 0.14, bleed: 1, core: 0.32),
  'focus': _felt(PaintKey.focus).copyWith(
    w: 2.2,
    alpha: 0.95,
    wob: const Wobble(amp: 0.9, wl: 70, tr: 0.16),
    halo: 0.16,
    bleed: 1.2,
    core: 0.3,
    skip: 0.15,
  ),
  'pencil': _pencil(PaintKey.pencil),
  'red': _pencil(PaintKey.red, waxy: true).copyWith(alpha: 0.9, smear: 0.26),
  'green': _pencil(
    PaintKey.green,
    waxy: true,
  ).copyWith(alpha: 0.9, smear: 0.26),
  'orange': _pencil(
    PaintKey.tangerine,
    waxy: true,
  ).copyWith(alpha: 0.9, smear: 0.28),
  'bluepencil': _pencil(
    PaintKey.inkYou,
    waxy: true,
  ).copyWith(w: 1.4, alpha: 0.88, smear: 0.26),
};

Map<String, PenSpec> _build() {
  final out = <String, PenSpec>{};
  for (final MapEntry(key: name, value: spec) in _basePens.entries) {
    out[name] = spec;
    out['$name.fine'] = _withClass(spec, WeightClass.fine);
    out['$name.brush'] = _withClass(spec, WeightClass.brush);
  }
  out['terracotta'] = _marker(PaintKey.marker);
  out['hi'] = _marker(PaintKey.hi).copyWith(
    kind: PenKind.hl,
    w: 14,
    alpha: 0.52,
    nib: 1.45,
    edge: 0.14,
    wet: 0.2,
    bleed: 0.6,
    wob: const Wobble(amp: 0.5, wl: 160, tr: 0.05),
    step: 2.4,
    cutK: 0.28,
  );
  for (final accent in Accent.values) {
    final color = PaintKey.values.byName(accent.name);
    out['m_${accent.name}'] = _marker(color);
    out['f_${accent.name}'] = _felt(color);
  }
  return out;
}

final Map<String, PenSpec> _pens = _build();

/// The named pens.
///
/// Mirrors `PenName` and `PENS` in `src/lib/ink/types.ts` and `pens.ts`.
enum PenName implements Pen {
  ink('ink'),
  inkFine('ink.fine'),
  inkBrush('ink.brush'),
  blue('blue'),
  blueFine('blue.fine'),
  blueBrush('blue.brush'),
  redfelt('redfelt'),
  redfeltFine('redfelt.fine'),
  redfeltBrush('redfelt.brush'),
  greenfelt('greenfelt'),
  greenfeltFine('greenfelt.fine'),
  greenfeltBrush('greenfelt.brush'),
  focus('focus'),
  focusFine('focus.fine'),
  focusBrush('focus.brush'),
  pencil('pencil'),
  pencilFine('pencil.fine'),
  pencilBrush('pencil.brush'),
  red('red'),
  redFine('red.fine'),
  redBrush('red.brush'),
  green('green'),
  greenFine('green.fine'),
  greenBrush('green.brush'),
  orange('orange'),
  orangeFine('orange.fine'),
  orangeBrush('orange.brush'),
  bluepencil('bluepencil'),
  bluepencilFine('bluepencil.fine'),
  bluepencilBrush('bluepencil.brush'),
  terracotta('terracotta'),
  hi('hi'),
  mTomato('m_tomato'),
  mTangerine('m_tangerine'),
  mLemon('m_lemon'),
  mGrass('m_grass'),
  mTeal('m_teal'),
  mSky('m_sky'),
  mGrape('m_grape'),
  mBubblegum('m_bubblegum'),
  fTomato('f_tomato'),
  fTangerine('f_tangerine'),
  fLemon('f_lemon'),
  fGrass('f_grass'),
  fTeal('f_teal'),
  fSky('f_sky'),
  fGrape('f_grape'),
  fBubblegum('f_bubblegum');

  const PenName(this.id);

  /// The upstream name, e.g. `pencil.fine` or `m_lemon`.
  final String id;

  @override
  PenSpec get spec => switch (_pens[id]) {
    final PenSpec spec => spec,
    null => throw StateError('ink: unknown pen "$id"'),
  };

  /// The pen with this upstream [id], or null.
  static PenName? byId(String id) {
    for (final pen in values) {
      if (pen.id == id) return pen;
    }
    return null;
  }
}

/// Resolves a pen to its spec (`pen()` upstream; use [PenSpec.copyWith] for
/// overrides, and [Wobble.copyWith] for a partial `wob`).
PenSpec pen(Pen p) => p.spec;
