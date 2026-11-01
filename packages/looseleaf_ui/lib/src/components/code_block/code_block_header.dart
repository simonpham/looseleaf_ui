import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/code_block/code_block.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The typed line at the top of a [CodeBlock], ruled off with a dashed
/// pencil line: a row of [CodeBlockTitle], [CodeBlockStats] and
/// [CodeBlockActions] in Kevin Sans Type, muted.
///
/// Mirrors `CodeBlockHeader` in upstream `src/components/ui/code-block.tsx`.
class CodeBlockHeader extends StatelessWidget {
  const CodeBlockHeader({super.key, required this.children});

  /// The header's parts; give the title an `Expanded` share by default
  /// ([CodeBlockTitle] takes one itself).
  final List<Widget> children;

  /// `text-[13px] tracking-wide`.
  static TextStyle style(LooseleafThemeData theme) => theme.typography
      .face(KevinSansFace.type, cssSize: 13, color: theme.colors.inkMuted)
      .copyWith(letterSpacing: 13 * 0.025);

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final scope = CodeBlockScope.of(context);
    return InkSurface(
      source: RecipeInkSource(
        codeRuleRecipe,
        const NoParams(),
        json: const NoParams().toJson(),
      ),
      seed: '${scope.seed}|rule',
      still: true,
      child: DefaultTextStyle.merge(
        style: style(theme),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.d16,
            Spacing.d14,
            Spacing.d16,
            Spacing.d10,
          ),
          child: Semantics(
            container: true,
            child: Row(spacing: Spacing.d12, children: children),
          ),
        ),
      ),
    );
  }
}
