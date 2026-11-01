import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A section's heading in the typewriter, muted, 32 px high. Collapsed to
/// icons it fades and closes up.
///
/// Mirrors `SidebarGroupLabel` in upstream `src/components/ui/sidebar.tsx`.
class SidebarGroupLabel extends StatelessWidget {
  const SidebarGroupLabel({super.key, required this.child, this.leading});

  /// The heading, usually a [Text].
  final Widget child;

  /// An icon before it.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final icons = SidebarPanelScope.iconsOf(context);
    final label = InkContent(
      style: theme.typography
          .face(
            KevinSansFace.type,
            cssSize: 14,
            cssLineHeight: 20 / 14,
            color: theme.colors.inkMuted,
          )
          .copyWith(letterSpacing: 0.025 * 14 * KevinSansFace.type.sizeAdjust),
      iconSize: Spacing.d16,
      wrap: false,
      child: SizedBox(
        height: Spacing.d32,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
          child: Row(
            spacing: Spacing.d8,
            children: [
              ?leading,
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(
        end: switch (icons) {
          true => 1,
          false => 0,
        },
      ),
      duration: InkMotion.of(context, InkMotion.sheet),
      curve: InkMotion.easeOut,
      builder: (context, folded, child) => Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1 - folded,
        child: Opacity(opacity: 1 - folded, child: child),
      ),
      child: label,
    );
  }
}
