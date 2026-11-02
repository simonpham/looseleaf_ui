import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A small button at the end of a row (a menu of row actions), given to
/// [SidebarMenuItem.action]. With [showOnHover] it only shows while the
/// row is hovered or holds focus (always on phones). Hidden when collapsed
/// to icons.
///
/// Mirrors `SidebarMenuAction` in upstream `src/components/ui/sidebar.tsx`.
class SidebarMenuAction extends StatelessWidget {
  const SidebarMenuAction({
    super.key,
    required this.child,
    this.onPressed,
    this.showOnHover = false,
    this.semanticLabel,
    this.focusNode,
    this.forcedStates = const {},
    this.fill = false,
  });

  /// The icon.
  final Widget child;

  /// Called on tap, Enter and Space.
  final VoidCallback? onPressed;

  /// Only visible while the row is hovered or focused.
  final bool showOnHover;

  /// The accessible name.
  final String? semanticLabel;

  final FocusNode? focusNode;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  /// Lays the pad's colour under the icon (upstream's `bg-sidebar`), so an
  /// action over the row's icon hides it while shown.
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final panel = SidebarPanelScope.maybeOf(context);
    if (panel?.collapsedToIcons ?? false) return const SizedBox.shrink();
    Widget button = SidebarActionButton(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      forcedStates: forcedStates,
      child: child,
    );
    if (fill) {
      button = ColoredBox(
        color: LooseleafTheme.of(context).colors.pad,
        child: button,
      );
    }
    final engaged = SidebarMenuItemScope.maybeOf(context)?.engaged;
    if (!showOnHover || (panel?.mobile ?? false) || engaged == null) {
      return button;
    }
    return ValueListenableBuilder(
      valueListenable: engaged,
      builder: (context, bool shown, child) => AnimatedOpacity(
        opacity: switch (shown || forcedStates.isNotEmpty) {
          true => 1,
          false => 0,
        },
        duration: InkMotion.of(context, InkMotion.hover),
        child: child,
      ),
      child: button,
    );
  }
}
