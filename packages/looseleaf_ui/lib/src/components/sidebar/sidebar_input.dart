import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An [Input] sized for the pad: full width, 32 px high.
///
/// Mirrors `SidebarInput` in upstream `src/components/ui/sidebar.tsx`.
class SidebarInput extends StatelessWidget {
  const SidebarInput({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.semanticLabel,
    this.seed,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// The hint shown while empty.
  final String? placeholder;

  /// Called on each edit.
  final ValueChanged<String>? onChanged;

  /// Called on Enter.
  final ValueChanged<String>? onSubmitted;

  /// The field's accessible name.
  final String? semanticLabel;

  /// Pins the frame.
  final String? seed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: Spacing.d32,
    child: Input(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      semanticLabel: semanticLabel,
      seed: seed,
    ),
  );
}
