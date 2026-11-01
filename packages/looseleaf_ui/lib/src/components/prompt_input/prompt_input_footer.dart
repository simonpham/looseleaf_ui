import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/prompt_input/prompt_input.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The row under the line: [PromptInputTools] at the start, a
/// [PromptInputHint], the [PromptInputSubmit] at the end.
///
/// Mirrors `PromptInputFooter` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputFooter extends StatelessWidget {
  const PromptInputFooter({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Spacing.d4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: Spacing.d8,
      children: [
        for (final child in children)
          switch (child) {
            PromptInputHint() => Flexible(child: child),
            _ => child,
          },
      ],
    ),
  );
}
