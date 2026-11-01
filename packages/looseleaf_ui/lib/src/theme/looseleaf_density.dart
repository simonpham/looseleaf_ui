/// How tightly components are drawn, Looseleaf's `data-density`.
enum LooseleafDensity {
  /// The default look.
  comfortable,

  /// Smaller hit targets, slightly thinner and steadier strokes.
  compact,

  /// Low wobble, no misregistration, no tilt, no motion.
  calm,
}

/// The ink detail tier: `lo` draws fewer points, `hi` draws richer strokes.
enum LooseleafTier { lo, hi }

/// Whether ink animates its state changes.
enum LooseleafMotion {
  /// Follow the platform's reduce-motion setting.
  system,

  /// Never animate.
  reduced,
}
