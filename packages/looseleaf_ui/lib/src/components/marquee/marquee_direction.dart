/// Which way a marquee's text runs.
///
/// Mirrors the `direction` prop of upstream `src/components/ui/marquee.tsx`.
enum MarqueeDirection {
  /// Toward the start of the line, like a news ticker (mirrored in RTL).
  start,

  /// Away from the start of the line.
  end,
}
