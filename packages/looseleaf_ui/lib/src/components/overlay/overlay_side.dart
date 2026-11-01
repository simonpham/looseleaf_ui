/// The side of its anchor a popup opens on.
///
/// Mirrors Radix's `side` (`data-side`).
enum OverlaySide {
  top,
  right,
  bottom,
  left;

  /// The side across the anchor.
  OverlaySide get opposite => switch (this) {
    OverlaySide.top => OverlaySide.bottom,
    OverlaySide.bottom => OverlaySide.top,
    OverlaySide.left => OverlaySide.right,
    OverlaySide.right => OverlaySide.left,
  };

  /// Whether the popup sits above or below the anchor.
  bool get vertical => this == OverlaySide.top || this == OverlaySide.bottom;
}

/// How a popup lines up with its anchor along the side: its start, centre or
/// end edge on the anchor's (logical, so mirrored in right-to-left layouts).
///
/// Mirrors Radix's `align` (`data-align`).
enum OverlayAlign { start, center, end }
