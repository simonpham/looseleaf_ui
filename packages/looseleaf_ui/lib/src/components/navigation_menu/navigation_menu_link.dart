import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/navigation_menu/navigation_menu.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A link of a [NavigationMenu]. Inside a panel it is a row in the hand
/// face, 8 px in, that wears the highlighter swipe under the pointer, with
/// keyboard focus and while [active]; pressing it closes the menu. In the
/// strip it is a tab like the triggers, and the current page ([active]) is
/// filled with highlighter.
///
/// Announced as a link, selected when [active] (`aria-current="page"`).
///
/// Mirrors `NavigationMenuLink` in upstream
/// `src/components/ui/navigation-menu.tsx`.
class NavigationMenuLink extends StatefulWidget {
  const NavigationMenuLink({
    super.key,
    required this.child,
    this.onPressed,
    this.active = false,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// The label; a title and a line in a panel, a word in the strip.
  final Widget child;

  /// Follows the link.
  final VoidCallback? onPressed;

  /// The current page.
  final bool active;

  /// Pins the hand of a strip tab.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<NavigationMenuLink> createState() => _NavigationMenuLinkState();
}

class _NavigationMenuLinkState extends State<NavigationMenuLink>
    with NavigationMenuRoving {
  static const BorderRadius _swipe = BorderRadius.only(
    topLeft: Radius.elliptical(3, 8),
    topRight: Radius.elliptical(8, 3),
    bottomRight: Radius.elliptical(4, 9),
    bottomLeft: Radius.elliptical(9, 4),
  );

  @override
  FocusNode? get externalFocusNode => widget.focusNode;

  @override
  bool get rovingEnabled => true;

  @override
  Widget build(BuildContext context) {
    syncRoving();
    final menu = NavigationMenu.maybeOf(context);
    final inPanel = NavigationMenuPanelScope.of(context);
    void follow() {
      widget.onPressed?.call();
      if (inPanel) menu?.close();
    }

    return Semantics(
      container: true,
      link: true,
      selected: widget.active,
      child: InkInteraction(
        onActivate: follow,
        focusNode: rovingFocusNode,
        autofocus: widget.autofocus,
        states: {
          ...widget.forcedStates,
          if (widget.active) InkState.checked,
        },
        builder: (context, states) => switch (inPanel) {
          true => _row(context, states),
          false => NavigationMenuTab(
            seed: widget.seed,
            states: states,
            child: widget.child,
          ),
        },
      ),
    );
  }

  Widget _row(BuildContext context, Set<InkState> states) {
    final theme = LooseleafTheme.of(context);
    final swiped =
        states.contains(InkState.hovered) ||
        states.contains(InkState.focused) ||
        states.contains(InkState.checked);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: switch (swiped) {
          true => theme.colors.hiSelect,
          false => null,
        },
        borderRadius: _swipe,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.d8),
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 16,
            color: switch (swiped) {
              true => theme.colors.selectionText,
              false => theme.colors.ink,
            },
          ),
          child: IconTheme.merge(
            data: IconThemeData(size: Spacing.d16, color: theme.colors.inkSoft),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
