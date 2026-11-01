import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/form/form.dart';

/// A form: its [controller] holds the values and errors of every
/// [InkFormField] under it. Validate with the controller's `handleSubmit`.
///
/// Named `InkForm` because Flutter's widgets library has a `Form`.
///
/// ```dart
/// InkForm(
///   controller: form,
///   child: Column(children: [
///     InkFormField<String>(
///       name: 'email',
///       validator: (value) => switch (value) {
///         final email? when email.contains('@') => null,
///         _ => 'Enter an address like ada@notes.dev.',
///       },
///       builder: (context, field) => FormItem(children: [
///         const FormLabel(Text('Email')),
///         FormControl(
///           child: Input(invalid: field.invalid, onChanged: field.onChanged),
///         ),
///         const FormMessage(),
///       ]),
///     ),
///     Button(
///       onPressed: () => form.handleSubmit(save),
///       child: const Text('Save'),
///     ),
///   ]),
/// )
/// ```
///
/// Mirrors `Form` (react-hook-form's `FormProvider`) in upstream
/// `src/components/ui/form.tsx`.
class InkForm extends StatelessWidget {
  const InkForm({
    super.key,
    required this.controller,
    required this.child,
    this.semanticLabel,
  });

  final FormController controller;
  final Widget child;

  /// The form's accessible name.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => FormScope(
    controller: controller,
    child: Semantics(
      container: true,
      role: SemanticsRole.form,
      label: semanticLabel,
      child: child,
    ),
  );
}
