import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';
import 'package:looseleaf_ui/src/components/separator/separator.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A pencil rule between groups, reaching over the list's padding; it
/// hides while a search is typed (cmdk's default).
///
/// Mirrors `CommandSeparator` in upstream `src/components/ui/command.tsx`.
class CommandSeparator extends StatelessWidget {
  const CommandSeparator({super.key, this.alwaysRender = false, this.seed});

  /// Keeps it while searching.
  final bool alwaysRender;

  /// Pins the rule.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final controller = CommandScope.of(context);
    if (!alwaysRender && controller.search.isNotEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.d4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const SizedBox(height: Spacing.d1, width: double.infinity),
          Positioned(
            left: -CommandMetrics.inset,
            right: -CommandMetrics.inset,
            top: 0,
            bottom: 0,
            child: Separator(seed: seed),
          ),
        ],
      ),
    );
  }
}
