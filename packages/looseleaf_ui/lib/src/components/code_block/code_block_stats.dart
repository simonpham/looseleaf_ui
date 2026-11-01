import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/code_block/code_block.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// `+14 -3` in green and red for a diff, read as "Added 14, Removed 3";
/// nothing for plain code.
///
/// Mirrors `CodeBlockStats` in upstream `src/components/ui/code-block.tsx`.
class CodeBlockStats extends StatelessWidget {
  const CodeBlockStats({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = CodeBlockScope.of(context).model.stats;
    if (stats == null) return const SizedBox.shrink();
    final colors = LooseleafTheme.of(context).colors;
    const tabular = [FontFeature.tabularFigures()];
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d8,
      children: [
        Semantics(
          container: true,
          label: 'Added ${stats.added}',
          excludeSemantics: true,
          child: Text(
            '+${stats.added}',
            style: TextStyle(color: colors.green, fontFeatures: tabular),
          ),
        ),
        Semantics(
          container: true,
          label: 'Removed ${stats.removed}',
          excludeSemantics: true,
          child: Text(
            '-${stats.removed}',
            style: TextStyle(color: colors.red, fontFeatures: tabular),
          ),
        ),
      ],
    );
  }
}
