import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/form/form_validation_mode.dart';

/// Checks a value; returns the message to show, or null when it is fine.
typedef FormValidator = String? Function(Object? value);

/// The values and errors of an [InkForm], the small Flutter stand-in for
/// react-hook-form's `useForm`.
///
/// Fields register a name and a validator. [mode] says when a field is
/// checked before the first [handleSubmit]: by default only on submit
/// (react-hook-form's `mode: "onSubmit"`); [FormValidationMode.onTouched]
/// checks it when it first loses focus, then on every change. After a
/// submit a field is checked again on every change
/// (`reValidateMode: "onChange"`). `InkFormField` reports blurs through
/// [markTouched]. [setError] puts a message on a field from outside, like a server error;
/// the field's next change clears it.
///
/// ```dart
/// final form = FormController(
///   initialValues: {'email': ''},
///   mode: FormValidationMode.onTouched,
/// );
/// form.handleSubmit((values) => save(values['email']));
/// ```
class FormController extends ChangeNotifier {
  FormController({
    Map<String, Object?> initialValues = const {},
    this.mode = FormValidationMode.onSubmit,
  }) : _initial = Map.of(initialValues),
       _values = Map.of(initialValues);

  /// When fields are checked before the first submit.
  final FormValidationMode mode;

  final Map<String, Object?> _initial;
  final Map<String, Object?> _values;
  final Map<String, String> _errors = {};
  final Map<String, FormValidator> _validators = {};
  final Map<String, FocusNode> _focus = {};
  final Set<String> _touched = {};
  var _submitted = false;
  var _submitting = false;

  /// Every value by field name.
  Map<String, Object?> get values => Map.unmodifiable(_values);

  /// Every current error by field name.
  Map<String, String> get errors => Map.unmodifiable(_errors);

  /// Whether a submit has been tried (react-hook-form's `isSubmitted`).
  bool get isSubmitted => _submitted;

  /// Whether a submit's callback is running.
  bool get isSubmitting => _submitting;

  /// The fields that have lost focus at least once (`touchedFields`).
  Set<String> get touchedFields => Set.unmodifiable(_touched);

  /// Whether [name] has lost focus at least once.
  bool isTouched(String name) => _touched.contains(name);

  /// Whether no field has an error.
  bool get isValid => _errors.isEmpty;

  /// The value of [name].
  T? value<T>(String name) => switch (_values[name]) {
    final T value => value,
    _ => null,
  };

  /// The error message of [name], if any.
  String? error(String name) => _errors[name];

  /// Sets [name] to [value]; checks it when [mode] asks for it, and
  /// always after a submit.
  void setValue(String name, Object? value) {
    _values[name] = value;
    _errors.remove(name);
    final touched = _touched.contains(name);
    if (_submitted || mode.checksOnChange(touched: touched)) _check(name);
    notifyListeners();
  }

  /// Records that [name] lost focus (react-hook-form's `onBlur`); checks it
  /// when [mode] asks for it. Called by `InkFormField`.
  void markTouched(String name) {
    _touched.add(name);
    if (!mode.checksOnBlur) return;
    _check(name);
    notifyListeners();
  }

  /// Puts [message] on [name] (null clears it), like `setError`.
  void setError(String name, String? message) {
    if (message == null) {
      _errors.remove(name);
      notifyListeners();
      return;
    }
    _errors[name] = message;
    notifyListeners();
  }

  /// Checks every field (or only [name]); true when they pass.
  bool validate([String? name]) {
    if (name != null) {
      _check(name);
      notifyListeners();
      return !_errors.containsKey(name);
    }
    _validators.keys.forEach(_check);
    notifyListeners();
    return _errors.isEmpty;
  }

  /// Marks the form submitted and checks it. When it passes, calls
  /// [onValid] with the values; otherwise focuses the first field in error
  /// and calls [onInvalid] with the errors.
  Future<void> handleSubmit(
    FutureOr<void> Function(Map<String, Object?> values) onValid, {
    void Function(Map<String, String> errors)? onInvalid,
  }) async {
    _submitted = true;
    if (!validate()) {
      _focusFirstError();
      onInvalid?.call(errors);
      return;
    }
    _submitting = true;
    notifyListeners();
    try {
      await onValid(values);
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Back to the initial values, no errors, nothing touched, not
  /// submitted.
  void reset([Map<String, Object?>? values]) {
    _values
      ..clear()
      ..addAll(values ?? _initial);
    _errors.clear();
    _touched.clear();
    _submitted = false;
    notifyListeners();
  }

  /// Registers [name]'s validator; called by `InkFormField`.
  void register(String name, FormValidator? validator) {
    if (validator == null) {
      _validators.remove(name);
      return;
    }
    _validators[name] = validator;
  }

  /// Forgets [name]'s validator and error; its value stays.
  void unregister(String name) {
    _validators.remove(name);
    _errors.remove(name);
    _focus.remove(name);
    _touched.remove(name);
  }

  /// Registers the node holding [name]'s control, so a failed submit can
  /// focus it; called by `FormControl`.
  void registerFocus(String name, FocusNode? node) {
    if (node == null) {
      _focus.remove(name);
      return;
    }
    _focus[name] = node;
  }

  void _check(String name) {
    final message = _validators[name]?.call(_values[name]);
    if (message == null) {
      _errors.remove(name);
      return;
    }
    _errors[name] = message;
  }

  void _focusFirstError() {
    for (final MapEntry(key: name, value: node) in _focus.entries) {
      if (!_errors.containsKey(name)) continue;
      final target = node.traversalDescendants.firstOrNull ?? node;
      target.requestFocus();
      return;
    }
  }
}
