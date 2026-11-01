import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A count at the end of a row, written in blue felt in the script font,
/// given to [SidebarMenuItem.badge]. Hidden when collapsed to icons.
///
/// Mirrors `SidebarMenuBadge` in upstream `src/components/ui/sidebar.tsx`.
class SidebarMenuBadge extends StatelessWidget {
  const SidebarMenuBadge({super.key, required this.child});

  /// The count, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (SidebarPanelScope.iconsOf(context)) return const SizedBox.shrink();
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: Spacing.d20,
        minHeight: Spacing.d20,
        maxHeight: Spacing.d20,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.d4),
        child: Center(
          widthFactor: 1,
          child: DefaultTextStyle.merge(
            style: theme.typography
                .face(
                  KevinSansFace.script,
                  cssSize: 18,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w600,
                  color: theme.colors.inkYou,
                )
                .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            child: child,
          ),
        ),
      ),
    );
  }
}
