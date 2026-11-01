import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/components/textarea/textarea_metrics.dart';

/// The bare multiline control: an [InputControl] that wraps, grows with
/// its text (`field-sizing-content`) or fills its box and scrolls, with
/// the textarea's `px-3 py-2` inset. No drawing.
///
/// Mirrors `TextareaControl` in upstream `src/components/ui/textarea.tsx`.
class TextareaControl extends StatelessWidget {
  const TextareaControl({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.disabled = false,
    this.readOnly = false,
    this.autofocus = false,
    this.autoGrow = true,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.padding = TextareaMetrics.padding,
    this.onChanged,
    this.semanticLabel,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Graphite text shown while the field is empty.
  final String? placeholder;

  /// Graphite text, no editing, out of the tab order.
  final bool disabled;

  /// Focusable and selectable, not editable.
  final bool readOnly;

  final bool autofocus;

  /// Grows with its text; false fills the height it is given and scrolls.
  final bool autoGrow;

  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// The inset around the text.
  final EdgeInsetsGeometry padding;

  final ValueChanged<String>? onChanged;

  /// The accessible name, when no visible label names the field.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => InputControl(
    controller: controller,
    focusNode: focusNode,
    placeholder: placeholder,
    disabled: disabled,
    readOnly: readOnly,
    autofocus: autofocus,
    keyboardType: keyboardType ?? TextInputType.multiline,
    textInputAction: TextInputAction.newline,
    textCapitalization: textCapitalization,
    inputFormatters: inputFormatters,
    maxLines: null,
    expands: !autoGrow,
    padding: padding,
    alignment: AlignmentDirectional.topStart,
    onChanged: onChanged,
    semanticLabel: semanticLabel,
  );
}
