import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A short note in the footer ("Enter to send"): small, muted.
///
/// Mirrors `PromptInputHint` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputHint extends StatelessWidget {
  const PromptInputHint(this.child, {super.key});

  /// The note, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.d4),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 14,
          cssLineHeight: 20 / 14,
          color: theme.colors.inkMuted,
        ),
        child: child,
      ),
    );
  }
}
