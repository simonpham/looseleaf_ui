import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input_group/input_group_scope.dart';
import 'package:looseleaf_ui/src/components/textarea/textarea.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The multiline control of an [InputGroup]: a [TextareaControl] that grows
/// with its text, with the group's focus node and states and a `py-3`
/// inset. It has no resize grip.
///
/// Mirrors `InputGroupTextarea` in upstream
/// `src/components/ui/input-group.tsx`.
class InputGroupTextarea extends StatelessWidget {
  const InputGroupTextarea({
    super.key,
    this.controller,
    this.placeholder,
    this.readOnly = false,
    this.autofocus = false,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.semanticLabel,
  });

  final TextEditingController? controller;

  /// Graphite text shown while the field is empty.
  final String? placeholder;

  final bool readOnly;
  final bool autofocus;

  /// The lines it shows at least (upstream `rows`).
  final int? minLines;

  /// The most characters it takes.
  final int? maxLength;

  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  /// The accessible name.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final group = InputGroupScope.maybeOf(context);
    final lines = minLines;
    final control = TextareaControl(
      controller: controller,
      focusNode: group?.focusNode,
      placeholder: placeholder,
      disabled: group?.disabled ?? false,
      readOnly: readOnly,
      autofocus: autofocus,
      inputFormatters: [
        ...?inputFormatters,
        if (maxLength case final max?) LengthLimitingTextInputFormatter(max),
      ],
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: Spacing.d12,
        vertical: Spacing.d12,
      ),
      onChanged: onChanged,
      semanticLabel: semanticLabel,
    );
    if (lines == null) return control;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: Spacing.d24 * lines + Spacing.d12 * 2,
      ),
      child: control,
    );
  }
}
