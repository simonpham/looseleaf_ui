/// How a preview stage places an example, upstream `ExampleMeta.layout`.
enum ExampleLayout {
  /// Centered and wrapped, with roomy padding.
  center,

  /// A column from the start edge, at most a readable width.
  stack,

  /// Edge to edge.
  full,
}

/// The surface under a preview, upstream `ExampleMeta.stage`.
enum ExampleStage { paper, desk }
