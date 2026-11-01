import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/field/field.dart';
import 'package:looseleaf_ui/src/components/form/form.dart';

/// A field's label: red while the field has an error; a tap focuses the
/// [FormControl].
///
/// Mirrors `FormLabel` in upstream `src/components/ui/form.tsx`.
class FormLabel extends StatelessWidget {
  const FormLabel(this.child, {super.key, this.required = false, this.seed});

  /// The words, usually a [Text].
  final Widget child;

  /// Draws the red required star.
  final bool required;

  /// Pins the star's hand.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final control = FormItemScope.maybeOf(context)?.control;
    return FieldScope(
      invalid: FormFieldData.maybeOf(context)?.invalid ?? false,
      disabled: false,
      child: FieldLabel(
        required: required,
        seed: seed,
        onPressed: switch (control) {
          null => null,
          final node =>
            () => node.traversalDescendants.firstOrNull?.requestFocus(),
        },
        child: child,
      ),
    );
  }
}
