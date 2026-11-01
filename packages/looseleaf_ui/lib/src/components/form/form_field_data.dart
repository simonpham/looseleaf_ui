import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/form/form_controller.dart';

/// One field's state for its builder and parts, like upstream
/// `useFormField` and react-hook-form's `field` / `fieldState`.
class FormFieldData<T> {
  const FormFieldData({
    required this.name,
    required this.controller,
  });

  /// The field's name in the form.
  final String name;

  final FormController controller;

  /// The current value.
  T? get value => controller.value<T>(name);

  /// The current error message.
  String? get error => controller.error(name);

  /// Whether the field has an error.
  bool get invalid => error != null;

  /// Sets the value; wire it to the control's `onChanged`.
  void onChanged(T? value) => controller.setValue(name, value);

  /// The nearest field's data, like `useFormField`.
  static FormFieldData<Object?> of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<FormFieldDataScope>();
    if (scope == null) {
      throw FlutterError('FormFieldData.of() called outside an InkFormField.');
    }
    return scope.data;
  }

  /// The nearest field's data, or null outside one.
  static FormFieldData<Object?>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FormFieldDataScope>()?.data;
}

/// Hands an `InkFormField`'s data to its item's parts.
class FormFieldDataScope extends InheritedWidget {
  const FormFieldDataScope({
    super.key,
    required this.data,
    required this.error,
    required super.child,
  });

  final FormFieldData<Object?> data;

  /// The error when built, so parts rebuild when it changes.
  final String? error;

  @override
  bool updateShouldNotify(FormFieldDataScope oldWidget) =>
      oldWidget.error != error || oldWidget.data.name != data.name;
}
