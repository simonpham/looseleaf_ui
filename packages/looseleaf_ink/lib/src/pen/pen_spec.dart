import 'package:looseleaf_ink/src/core/core.dart';

/// Something that resolves to a [PenSpec]: a [PenName] or a spec itself.
///
/// Upstream takes `PenName | PenSpec` wherever a pen is expected.
abstract interface class Pen {
  /// The resolved spec.
  PenSpec get spec;
}

/// The low-frequency wobble of a pen: amplitude, wavelength and tremor.
final class Wobble {
  /// A wobble.
  const Wobble({required this.amp, required this.wl, required this.tr});

  /// Amplitude.
  final double amp;

  /// Wavelength.
  final double wl;

  /// Tremor.
  final double tr;

  /// A copy with some fields replaced.
  Wobble copyWith({double? amp, double? wl, double? tr}) =>
      Wobble(amp: amp ?? this.amp, wl: wl ?? this.wl, tr: tr ?? this.tr);
}

/// Every knob of a pen.
///
/// Mirrors `PenSpec` in `src/lib/ink/types.ts`; `W` is [w].
final class PenSpec implements Pen {
  /// A pen.
  const PenSpec({
    required this.kind,
    required this.color,
    required this.grain,
    required this.cls,
    required this.w,
    required this.alpha,
    required this.wob,
    required this.step,
    required this.halo,
    required this.bleed,
    required this.core,
    required this.pool,
    required this.feather,
    required this.skip,
    required this.swell,
    required this.dir,
    required this.dryAmt,
    required this.dryWl,
    required this.gaps,
    required this.dens,
    required this.taper,
    required this.smear,
    required this.waxy,
    required this.nib,
    required this.edge,
    required this.wet,
    required this.cutK,
  });

  final PenKind kind;
  final PaintKey color;
  final GrainKind grain;
  final WeightClass cls;

  /// Nib width (`W`).
  final double w;
  final double alpha;
  final Wobble wob;
  final double step;
  final double halo;
  final double bleed;
  final double core;
  final double pool;
  final double feather;
  final double skip;
  final double swell;
  final double dir;
  final double dryAmt;
  final double dryWl;
  final double gaps;
  final double dens;
  final double taper;
  final double smear;
  final bool waxy;
  final double nib;
  final double edge;
  final double wet;
  final double cutK;

  @override
  PenSpec get spec => this;

  /// A copy with some fields replaced (`{ ...p, ...over }` upstream).
  PenSpec copyWith({
    PenKind? kind,
    PaintKey? color,
    GrainKind? grain,
    WeightClass? cls,
    double? w,
    double? alpha,
    Wobble? wob,
    double? step,
    double? halo,
    double? bleed,
    double? core,
    double? pool,
    double? feather,
    double? skip,
    double? swell,
    double? dir,
    double? dryAmt,
    double? dryWl,
    double? gaps,
    double? dens,
    double? taper,
    double? smear,
    bool? waxy,
    double? nib,
    double? edge,
    double? wet,
    double? cutK,
  }) => PenSpec(
    kind: kind ?? this.kind,
    color: color ?? this.color,
    grain: grain ?? this.grain,
    cls: cls ?? this.cls,
    w: w ?? this.w,
    alpha: alpha ?? this.alpha,
    wob: wob ?? this.wob,
    step: step ?? this.step,
    halo: halo ?? this.halo,
    bleed: bleed ?? this.bleed,
    core: core ?? this.core,
    pool: pool ?? this.pool,
    feather: feather ?? this.feather,
    skip: skip ?? this.skip,
    swell: swell ?? this.swell,
    dir: dir ?? this.dir,
    dryAmt: dryAmt ?? this.dryAmt,
    dryWl: dryWl ?? this.dryWl,
    gaps: gaps ?? this.gaps,
    dens: dens ?? this.dens,
    taper: taper ?? this.taper,
    smear: smear ?? this.smear,
    waxy: waxy ?? this.waxy,
    nib: nib ?? this.nib,
    edge: edge ?? this.edge,
    wet: wet ?? this.wet,
    cutK: cutK ?? this.cutK,
  );

  /// The spec as upstream's object shape, for fixtures and debugging.
  Map<String, Object> toJson() => {
    'kind': kind.name,
    'color': color.id,
    'grain': grain.name,
    'cls': cls.name,
    'W': w,
    'alpha': alpha,
    'wob': {'amp': wob.amp, 'wl': wob.wl, 'tr': wob.tr},
    'step': step,
    'halo': halo,
    'bleed': bleed,
    'core': core,
    'pool': pool,
    'feather': feather,
    'skip': skip,
    'swell': swell,
    'dir': dir,
    'dryAmt': dryAmt,
    'dryWl': dryWl,
    'gaps': gaps,
    'dens': dens,
    'taper': taper,
    'smear': smear,
    'waxy': waxy,
    'nib': nib,
    'edge': edge,
    'wet': wet,
    'cutK': cutK,
  };
}
