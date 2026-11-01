import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The caption in a polaroid's foot: the script face at 26 px, semibold,
/// centred, at least 48 px high.
///
/// Mirrors `PolaroidCaption` in upstream `src/components/ui/polaroid.tsx`.
class PolaroidCaption extends StatelessWidget {
  const PolaroidCaption(this.child, {super.key});

  /// Upstream's `min-h-12`.
  static const double minHeight = Spacing.d48;

  /// The caption, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.d4),
        child: Center(
          child: DefaultTextStyle.merge(
            style: theme.typography.face(
              KevinSansFace.script,
              cssSize: 26.4,
              cssLineHeight: 1.05,
              fontWeight: FontWeight.w600,
              color: theme.colors.ink,
            ),
            textAlign: TextAlign.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
