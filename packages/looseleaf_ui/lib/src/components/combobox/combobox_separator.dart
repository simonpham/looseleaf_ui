import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A rule between parts of the list, reaching the list's edges.
///
/// Upstream draws a pencil `Separator` (`-mx-1 my-1`); until it is ported
/// this is a hairline in `--ll-line-soft`.
///
/// Mirrors `ComboboxSeparator` in upstream `src/components/ui/combobox.tsx`.
class ComboboxSeparator extends StatelessWidget {
  const ComboboxSeparator({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.d4),
      child: SizedBox(
        height: Spacing.d1,
        child: ColoredBox(color: LooseleafTheme.of(context).colors.lineSoft),
      ),
    ),
  );
}
