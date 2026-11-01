import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A small button at the end of a group's label row (an add button), given
/// to [SidebarGroup.action]. Hidden when collapsed to icons.
///
/// Mirrors `SidebarGroupAction` in upstream `src/components/ui/sidebar.tsx`.
class SidebarGroupAction extends StatelessWidget {
  const SidebarGroupAction({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.focusNode,
    this.forcedStates = const {},
  });

  /// The icon.
  final Widget child;

  /// Called on tap, Enter and Space.
  final VoidCallback? onPressed;

  /// The accessible name.
  final String? semanticLabel;

  final FocusNode? focusNode;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) {
    if (SidebarPanelScope.iconsOf(context)) return const SizedBox.shrink();
    return SidebarActionButton(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      forcedStates: forcedStates,
      child: child,
    );
  }
}
