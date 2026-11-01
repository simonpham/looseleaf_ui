import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/field/field.dart';
import 'package:looseleaf_ui/src/components/form/form.dart';

/// The field's error in red over a wavy red underline; without an error it
/// shows [child], and with neither it draws nothing.
///
/// Mirrors `FormMessage` in upstream `src/components/ui/form.tsx`.
class FormMessage extends StatelessWidget {
  const FormMessage({super.key, this.child, this.seed});

  /// Shown when the field has no error.
  final Widget? child;

  /// Pins the underline's hand.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final error = FormFieldData.maybeOf(context)?.error;
    final body = switch (error) {
      final message? when message.isNotEmpty => Text(message),
      _ => child,
    };
    if (body == null) return const SizedBox.shrink();
    return FieldError(seed: seed, child: body);
  }
}
