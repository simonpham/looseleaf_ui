import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';
import 'package:looseleaf_ui/src/components/separator/separator.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A hand-drawn pencil rule between groups, reaching over the list's
/// padding to its edges.
///
/// Mirrors `SelectSeparator` in upstream `src/components/ui/select.tsx`.
class SelectSeparator extends StatelessWidget {
  const SelectSeparator({super.key, this.seed});

  /// Pins the rule.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final bleed = SelectMetrics.viewportPadding.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SelectMetrics.separatorGap),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const SizedBox(height: Spacing.d1, width: double.infinity),
          Positioned(
            left: -bleed,
            right: -bleed,
            top: 0,
            bottom: 0,
            child: Separator(seed: seed),
          ),
        ],
      ),
    );
  }
}
