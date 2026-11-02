import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The small square button of [SidebarGroupAction] and [SidebarMenuAction]:
/// 24 px, a 16 px icon, the highlighter on hover and keyboard focus, a
/// touch target 8 px bigger all round.
class SidebarActionButton extends StatelessWidget {
  const SidebarActionButton({
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
    final theme = LooseleafTheme.of(context);
    return InkInteraction(
      semantics: SemanticsProperties(
        button: true,
        label: semanticLabel,
      ),
      onActivate: onPressed,
      states: forcedStates,
      focusNode: focusNode,
      hitSlop: const EdgeInsets.all(Spacing.d8),
      builder: (context, states) => SidebarSwipe(
        on:
            states.contains(InkState.hovered) ||
            states.contains(InkState.focused),
        child: InkContent(
          style: theme.typography.face(
            KevinSansFace.hand,
            color: theme.colors.ink,
          ),
          iconSize: Spacing.d16,
          child: SizedBox.square(
            dimension: SidebarMetrics.action,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
