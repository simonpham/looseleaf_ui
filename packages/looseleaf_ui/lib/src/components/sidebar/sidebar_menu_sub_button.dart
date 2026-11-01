import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A sub-row's link: at least 28 px high, Kevin Sans Hand at 16 or 15 px;
/// a title that wraps makes the row taller. The current page ([isActive])
/// is bold on the highlighter; hover and keyboard focus lay it too.
///
/// Mirrors `SidebarMenuSubButton` in upstream
/// `src/components/ui/sidebar.tsx`.
class SidebarMenuSubButton extends StatelessWidget {
  const SidebarMenuSubButton({
    super.key,
    required this.child,
    this.leading,
    this.onPressed,
    this.isActive = false,
    this.size = SidebarMenuSubButtonSize.md,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// The title, usually a [Text].
  final Widget child;

  /// An icon before the title.
  final Widget? leading;

  /// Called on tap and Enter.
  final VoidCallback? onPressed;

  /// Marks the current page.
  final bool isActive;

  /// 16 or 15 px text.
  final SidebarMenuSubButtonSize size;

  /// Graphite text, no input.
  final bool disabled;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) {
    if (SidebarPanelScope.iconsOf(context)) return const SizedBox.shrink();
    return Semantics(
      container: true,
      link: true,
      selected: isActive,
      enabled: !disabled,
      child: InkInteraction(
        enabled: !disabled,
        onActivate: onPressed,
        states: forcedStates,
        focusNode: focusNode,
        autofocus: autofocus,
        builder: (context, states) => _body(context, states),
      ),
    );
  }

  Widget _body(BuildContext context, Set<InkState> states) {
    final theme = LooseleafTheme.of(context);
    final swiped =
        isActive ||
        states.contains(InkState.hovered) ||
        states.contains(InkState.focused);
    return SidebarSwipe(
      on: swiped,
      child: InkContent(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: switch (size) {
            SidebarMenuSubButtonSize.md => 16,
            SidebarMenuSubButtonSize.sm => 15,
          },
          cssLineHeight: 1.375,
          fontWeight: switch (isActive) {
            true => FontWeight.w700,
            false => FontWeight.w400,
          },
          color: switch (disabled) {
            true => theme.colors.pencilText,
            false => theme.colors.ink,
          },
        ),
        iconSize: Spacing.d16,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Spacing.d28),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.d8,
              vertical: Spacing.d2,
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: theme.colors.inkSoft),
              child: Row(
                spacing: Spacing.d8,
                children: [
                  ?leading,
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
