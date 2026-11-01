/// How a [Field] lays out its label and control.
///
/// Mirrors the `orientation` of upstream `fieldVariants`
/// (`src/components/ui/field.tsx`).
enum FieldOrientation {
  /// Label above the control.
  vertical,

  /// Label beside the control (a switch or checkbox).
  horizontal,

  /// Vertical until its [FieldGroup] is 448 px wide (`@md/field-group`),
  /// then horizontal.
  responsive,
}

/// How a [FieldLegend] is set.
enum FieldLegendVariant {
  /// The script face at 25.6 px.
  legend,

  /// A bold 15 px label.
  label,
}
