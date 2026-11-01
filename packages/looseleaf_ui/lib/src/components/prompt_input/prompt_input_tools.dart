import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A group of [PromptInputButton]s, 4 px apart.
///
/// Mirrors `PromptInputTools` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputTools extends StatelessWidget {
  const PromptInputTools({
    super.key,
    required this.children,
    this.semanticLabel,
  });

  final List<Widget> children;

  /// The group's accessible name.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: semanticLabel,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d4,
      children: children,
    ),
  );
}
