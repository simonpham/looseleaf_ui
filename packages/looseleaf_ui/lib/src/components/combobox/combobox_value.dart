import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds a custom value display from the chosen [values] and their labels.
typedef ComboboxValueBuilder = Widget Function(
  BuildContext context,
  List<String> values,
  String Function(String value) labelFor,
);

/// The chosen labels inside a [ComboboxTrigger], joined with commas and cut
/// with an ellipsis, or the graphite [placeholder] when nothing is chosen.
///
/// Mirrors `ComboboxValue` in upstream `src/components/ui/combobox.tsx`.
class ComboboxValue extends StatelessWidget {
  const ComboboxValue({super.key, this.placeholder, this.builder});

  /// Shown while nothing is chosen.
  final String? placeholder;

  /// Replaces the default text.
  final ComboboxValueBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final controller = ComboboxScope.of(context).controller;
    final builder = this.builder;
    if (builder != null) {
      return builder(context, controller.value, controller.labelFor);
    }
    final text = controller.value.map(controller.labelFor).join(', ');
    final empty = text.isEmpty;
    return Text(
      switch (empty) {
        true => placeholder ?? '',
        false => text,
      },
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: switch (empty) {
        true => TextStyle(color: LooseleafTheme.of(context).colors.placeholder),
        false => null,
      },
    );
  }
}
