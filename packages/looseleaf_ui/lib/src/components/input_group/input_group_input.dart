import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/components/input_group/input_group_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The one-line control of an [InputGroup]: an [InputControl] with the
/// group's focus node and states, its inset tightened beside inline addons.
///
/// Mirrors `InputGroupInput` in upstream `src/components/ui/input-group.tsx`.
class InputGroupInput extends StatelessWidget {
  const InputGroupInput({
    super.key,
    this.controller,
    this.placeholder,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.semanticLabel,
  });

  final TextEditingController? controller;

  /// Graphite text shown while the field is empty.
  final String? placeholder;

  final bool readOnly;
  final bool obscureText;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// The accessible name.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final group = InputGroupScope.maybeOf(context);
    final aligns = group?.aligns ?? const {};
    return InputControl(
      controller: controller,
      focusNode: group?.focusNode,
      placeholder: placeholder,
      disabled: group?.disabled ?? false,
      readOnly: readOnly,
      obscureText: obscureText,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      semanticLabel: semanticLabel,
      padding: EdgeInsetsDirectional.fromSTEB(
        switch (aligns.contains(InputGroupAlign.inlineStart)) {
          true => Spacing.d8,
          false => Spacing.d12,
        },
        switch (aligns.contains(InputGroupAlign.blockEnd)) {
          true => Spacing.d12,
          false => Spacing.d4,
        },
        switch (aligns.contains(InputGroupAlign.inlineEnd)) {
          true => Spacing.d8,
          false => Spacing.d12,
        },
        switch (aligns.contains(InputGroupAlign.blockStart)) {
          true => Spacing.d12,
          false => Spacing.d4,
        },
      ),
    );
  }
}
