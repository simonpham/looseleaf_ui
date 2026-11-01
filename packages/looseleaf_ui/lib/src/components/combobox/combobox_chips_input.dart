import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_metrics.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The input after the chips in [ComboboxChips]: typing filters and opens
/// the list, Backspace in the empty input takes the last chip back.
///
/// Mirrors `ComboboxChipsInput` in upstream `src/components/ui/combobox.tsx`.
class ComboboxChipsInput extends StatelessWidget {
  const ComboboxChipsInput({
    super.key,
    this.placeholder,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Graphite text while empty.
  final String? placeholder;

  final bool autofocus;

  /// The accessible name.
  final String? semanticLabel;

  /// `min-w-16`: the input's least width.
  static const double minWidth = Spacing.d64;

  @override
  Widget build(BuildContext context) {
    final controller = ComboboxScope.of(context).controller;
    final theme = LooseleafTheme.of(context);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, event) => controller.handleKey(event),
      child: DefaultTextStyle.merge(
        style: ComboboxMetrics.text(theme, color: theme.colors.inputInk),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: minWidth),
          child: IntrinsicWidth(
            child: SizedBox(
              height: ComboboxMetrics.chipHeight(theme.density),
              child: InputControl(
                controller: controller.text,
                focusNode: controller.inputFocus,
                placeholder: placeholder,
                disabled: controller.disabled,
                readOnly: controller.readOnly,
                autofocus: autofocus,
                semanticLabel: semanticLabel,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.d4),
                onChanged: (query) => controller.type(query, dirty: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
