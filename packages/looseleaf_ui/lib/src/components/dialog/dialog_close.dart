import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';

/// Anything that closes the nearest [Dialog] (or alert dialog, sheet,
/// drawer): [builder] gets a callback for your own control, like
/// upstream's `asChild` on a `Button`.
///
/// ```dart
/// DialogClose(
///   builder: (context, close) => Button(
///     variant: ButtonVariant.outline,
///     onPressed: close,
///     child: const Text('Cancel'),
///   ),
/// )
/// ```
///
/// Mirrors `DialogClose` in upstream `src/components/ui/dialog.tsx`.
class DialogClose extends StatelessWidget {
  const DialogClose({super.key, required this.builder});

  /// Builds the control with a callback that closes the dialog.
  final Widget Function(BuildContext context, VoidCallback close) builder;

  @override
  Widget build(BuildContext context) {
    final dialog = DialogScope.maybeOf(context);
    return builder(context, dialog?.close ?? () {});
  }
}
