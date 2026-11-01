import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/navigation_menu/navigation_menu.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A tab that opens its [NavigationMenuItem]'s panel: a faint pencil
/// sketch at rest, highlighter under the pointer, lifted with a wash while
/// open, its chevron turned over. Hover (with intent), a tap, Enter or
/// Space open it; Down steps into the open panel. Announced as a button
/// that is expanded or collapsed.
///
/// Mirrors `NavigationMenuTrigger` in upstream
/// `src/components/ui/navigation-menu.tsx`.
class NavigationMenuTrigger extends StatefulWidget {
  const NavigationMenuTrigger({
    super.key,
    required this.child,
    this.disabled = false,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// The label.
  final Widget child;

  /// A dashed pencil tab that does not open.
  final bool disabled;

  /// Pins the hand.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<NavigationMenuTrigger> createState() => _NavigationMenuTriggerState();
}

class _NavigationMenuTriggerState extends State<NavigationMenuTrigger>
    with NavigationMenuRoving {
  @override
  FocusNode? get externalFocusNode => widget.focusNode;

  @override
  bool get rovingEnabled => !widget.disabled;

  void _down(NavigationMenuController? menu, String? value) {
    if (menu == null || value == null || widget.disabled) return;
    if (menu.value != value) {
      menu.select(value);
      return;
    }
    menu.focusPanel();
  }

  @override
  Widget build(BuildContext context) {
    syncRoving();
    final menu = NavigationMenu.maybeOf(context);
    final value = NavigationMenuItemScope.maybeOf(context);
    final open = value != null && menu?.value == value;
    final enabled = !widget.disabled;
    void toggle() {
      if (value == null) return;
      menu?.toggle(value);
    }

    return Semantics(
      container: true,
      button: true,
      expanded: open,
      enabled: enabled,
      child: MouseRegion(
        onEnter: (_) {
          if (!enabled || value == null) return;
          menu?.hoverTrigger(value);
        },
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                _down(menu, value),
          },
          child: InkInteraction(
            enabled: enabled,
            onActivate: toggle,
            focusNode: rovingFocusNode,
            autofocus: widget.autofocus,
            states: {...widget.forcedStates, if (open) InkState.open},
            builder: (context, states) => NavigationMenuTab(
              key: switch (value) {
                final item? => menu?.triggerKey(item),
                null => null,
              },
              role: NavTabRole.trigger,
              states: states,
              disabled: widget.disabled,
              seed: widget.seed,
              trailing: _Chevron(open: states.contains(InkState.open)),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: const Offset(0, Spacing.d1),
    child: AnimatedRotation(
      turns: switch (open) {
        true => 0.5,
        false => 0,
      },
      duration: InkMotion.of(context, InkMotion.sheet),
      curve: InkMotion.settle,
      child: const InkIcon('chevron-down', size: Spacing.d16),
    ),
  );
}
