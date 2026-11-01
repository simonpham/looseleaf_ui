import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The chips above the line (files, images), wrapping 12 px apart; nothing
/// when empty.
///
/// Mirrors `PromptInputAttachments` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputAttachments extends StatelessWidget {
  const PromptInputAttachments({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(
        left: Spacing.d4,
        right: Spacing.d4,
        top: Spacing.d12,
      ),
      child: Wrap(
        spacing: Spacing.d12,
        runSpacing: Spacing.d12,
        children: children,
      ),
    );
  }
}
