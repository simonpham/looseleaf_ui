import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_metrics.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A small type heading in the list: `px-2 py-1.5 font-type text-xs
/// text-ink-muted`.
///
/// Mirrors `ComboboxLabel` in upstream `src/components/ui/combobox.tsx`.
class ComboboxLabel extends StatelessWidget {
  const ComboboxLabel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.d8,
        vertical: Spacing.d6,
      ),
      child: DefaultTextStyle.merge(
        style: ComboboxMetrics.heading(LooseleafTheme.of(context)),
        child: child,
      ),
    ),
  );
}
