import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_metrics.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/spinner/spinner.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A spinner row shown while the combobox is `loading`.
///
/// Mirrors `ComboboxLoading` in upstream `src/components/ui/combobox.tsx`
/// (`CommandLoading`).
class ComboboxLoading extends StatelessWidget {
  const ComboboxLoading({super.key, required this.child});

  /// The message, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!ComboboxScope.of(context).controller.loading) {
      return const SizedBox.shrink();
    }
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.d16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: Spacing.d8,
        children: [
          const Spinner(variant: SpinnerVariant.loops, size: Spacing.d14),
          DefaultTextStyle.merge(
            style: ComboboxMetrics.small(theme, color: theme.colors.inkMuted),
            child: child,
          ),
        ],
      ),
    );
  }
}
