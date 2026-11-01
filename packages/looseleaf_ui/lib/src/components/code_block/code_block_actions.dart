import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row for a [CodeBlockHeader]'s buttons.
///
/// Mirrors `CodeBlockActions` in upstream `src/components/ui/code-block.tsx`.
class CodeBlockActions extends StatelessWidget {
  const CodeBlockActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d4,
    children: children,
  );
}
