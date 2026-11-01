import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/form/form.dart';

/// Wraps a field's control: the [FormLabel] focuses it, a failed submit
/// focuses it, and screen readers hear it is invalid while the field has
/// an error. Pass `invalid: field.invalid` to the control to draw it red.
///
/// Mirrors `FormControl` in upstream `src/components/ui/form.tsx`.
class FormControl extends StatefulWidget {
  const FormControl({super.key, required this.child});

  /// The input, select, checkbox, …
  final Widget child;

  @override
  State<FormControl> createState() => _FormControlState();
}

class _FormControlState extends State<FormControl> {
  FormController? _controller;
  String? _name;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final field = FormFieldData.maybeOf(context);
    final control = FormItemScope.maybeOf(context)?.control;
    if (field == null) return;
    if (_name case final name? when name != field.name) {
      _controller?.registerFocus(name, null);
    }
    _controller = field.controller;
    _name = field.name;
    field.controller.registerFocus(field.name, control);
  }

  @override
  void dispose() {
    if (_name case final name?) _controller?.registerFocus(name, null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invalid = FormFieldData.maybeOf(context)?.invalid ?? false;
    final child = Semantics(
      validationResult: switch (invalid) {
        true => SemanticsValidationResult.invalid,
        false => SemanticsValidationResult.none,
      },
      child: widget.child,
    );
    final control = FormItemScope.maybeOf(context)?.control;
    if (control == null) return child;
    return Focus(
      focusNode: control,
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      child: child,
    );
  }
}
