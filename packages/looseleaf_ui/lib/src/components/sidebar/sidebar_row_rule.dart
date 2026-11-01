import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row's line of the pad's ruling: 1 px of `--ll-pad-rule` 4 px in from
/// the row's sides, just under it, fading a little along its length
/// (differently on [odd] and even rows).
///
/// Mirrors the `after:` rule and its `mask-image` gradients in upstream
/// `sidebarMenuButtonVariants`.
class SidebarRowRule extends StatelessWidget {
  const SidebarRowRule({super.key, required this.odd});

  /// Whether the row is odd (`group-odd/menu-item`).
  final bool odd;

  @override
  Widget build(BuildContext context) {
    final rule = LooseleafTheme.of(context).colors.padRule;
    final (alphas, stops) = switch (odd) {
      true => (const [1.0, 0.78, 1.0], const [0.0, 0.45, 1.0]),
      false => (const [0.82, 1.0, 0.86], const [0.0, 0.55, 1.0]),
    };
    return SizedBox(
      height: Spacing.d1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              for (final alpha in alphas) rule.withValues(alpha: alpha),
            ],
            stops: stops,
          ),
        ),
      ),
    );
  }
}
