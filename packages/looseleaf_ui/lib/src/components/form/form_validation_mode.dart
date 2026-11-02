/// When a [FormController] checks a field, like react-hook-form's `mode`.
///
/// After a submit has been tried, every mode also checks a field on each
/// change (react-hook-form's `reValidateMode: "onChange"`).
enum FormValidationMode {
  /// Only on submit (the default).
  onSubmit,

  /// When the field loses focus.
  onBlur,

  /// On every change.
  onChange,

  /// When the field first loses focus, then on every change.
  onTouched,

  /// On every blur and every change.
  all;

  /// Whether a blur checks the field.
  bool get checksOnBlur => switch (this) {
    FormValidationMode.onBlur ||
    FormValidationMode.onTouched ||
    FormValidationMode.all => true,
    FormValidationMode.onSubmit || FormValidationMode.onChange => false,
  };

  /// Whether a change checks the field, given whether it was [touched].
  bool checksOnChange({required bool touched}) => switch (this) {
    FormValidationMode.onChange || FormValidationMode.all => true,
    FormValidationMode.onTouched => touched,
    FormValidationMode.onSubmit || FormValidationMode.onBlur => false,
  };
}
