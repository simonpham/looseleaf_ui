import 'package:looseleaf_ink/src/core/core.dart';

/// `2π`.
const double tau = JsMath.pi * 2;

/// Output settings for a [Tier]: grid `q`, simplify tolerance and step scale.
///
/// Mirrors `TierCfg` in `src/lib/ink/geom.ts`.
final class TierCfg {
  /// Settings for one tier.
  const TierCfg({required this.q, required this.tol, required this.stepK});

  /// Path grid, in units per pixel (10, 20 or 100).
  final int q;

  /// Simplify tolerance, in pixels.
  final double tol;

  /// Sampling step multiplier.
  final double stepK;

  /// A copy with another tolerance.
  TierCfg withTol(double tol) => TierCfg(q: q, tol: tol, stepK: stepK);
}

/// The settings for [tier] (`TIERS[tier]`).
TierCfg tierCfg(Tier tier) => switch (tier) {
  Tier.hi => const TierCfg(q: 20, tol: 0.085, stepK: 1),
  Tier.lo => const TierCfg(q: 10, tol: 0.16, stepK: 1.5),
};
