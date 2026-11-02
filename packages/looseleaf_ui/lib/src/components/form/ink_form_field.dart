import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/form/form.dart';

/// Builds a field's control from its value and error. [validator] runs
/// when the form's `FormValidationMode` asks (on submit by default), and on
/// every change after a submit. When focus leaves the field the form marks
/// it touched, so `onBlur` / `onTouched` modes need no focus listeners. Wrap what [builder] returns in a
/// [FormItem] so the label, control and message find this field.
///
/// Named `InkFormField` because Flutter's widgets library has a
/// `FormField`.
///
/// Mirrors `FormField` (react-hook-form's `Controller`) in upstream
/// `src/components/ui/form.tsx`.
class InkFormField<T> extends StatefulWidget {
  const InkFormField({
    super.key,
    required this.name,
    required this.builder,
    this.validator,
  });

  /// The field's name in the form's values.
  final String name;

  /// Builds the control.
  final Widget Function(BuildContext context, FormFieldData<T> field) builder;

  /// Returns the error message for a value, or null.
  final String? Function(T? value)? validator;

  @override
  State<InkFormField<T>> createState() => _InkFormFieldState<T>();
}

class _InkFormFieldState<T> extends State<InkFormField<T>> {
  FormController? _controller;

  String? _validate(Object? value) => switch ((widget.validator, value)) {
    (null, _) => null,
    (final validator?, final T typed) => validator(typed),
    (final validator?, _) => validator(null),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = FormScope.of(context);
    if (identical(controller, _controller)) return;
    _controller?.unregister(widget.name);
    _controller = controller..register(widget.name, _validate);
  }

  @override
  void didUpdateWidget(InkFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name == widget.name) return;
    _controller
      ?..unregister(oldWidget.name)
      ..register(widget.name, _validate);
  }

  @override
  void dispose() {
    _controller?.unregister(widget.name);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = FormScope.of(context);
    final data = FormFieldData<T>(name: widget.name, controller: controller);
    return FormFieldDataScope(
      data: FormFieldData<Object?>(name: widget.name, controller: controller),
      error: data.error,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onFocusChange: (focused) {
          if (focused) return;
          controller.markTouched(widget.name);
        },
        child: Builder(builder: (context) => widget.builder(context, data)),
      ),
    );
  }
}
