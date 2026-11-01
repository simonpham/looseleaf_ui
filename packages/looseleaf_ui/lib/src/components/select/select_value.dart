import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The chosen item's content inside a [SelectTrigger], on one line, or
/// the graphite [placeholder] until something is chosen.
///
/// Mirrors `SelectValue` in upstream `src/components/ui/select.tsx`.
class SelectValue extends StatelessWidget {
  const SelectValue({super.key, this.placeholder});

  /// What it says while nothing is chosen.
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final select = Select.of(context);
    final theme = LooseleafTheme.of(context);
    final chosen = select.chosen;
    final Widget shown = switch (chosen) {
      final item? => item.child,
      null => Text(
        placeholder ?? '',
        style: TextStyle(
          color: switch (selectTriggerDisabled(context)) {
            true => theme.colors.pencilText,
            false => theme.colors.placeholder,
          },
        ),
      ),
    };
    return DefaultTextStyle.merge(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      child: shown,
    );
  }
}
