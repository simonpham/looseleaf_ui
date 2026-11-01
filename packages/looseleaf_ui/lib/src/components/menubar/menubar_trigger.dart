import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/components/menubar/menubar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A title on a [Menubar]'s strip, in bold hand lettering. Hovered,
/// focused or open, it wears the highlighter; keyboard focus adds the blue
/// focus ring. A tap opens or closes its menu; Enter, Space or Down open
/// it with the first row highlighted. While another menu is open, hovering
/// it switches to its menu.
///
/// Mirrors `MenubarTrigger` in upstream `src/components/ui/menubar.tsx`.
class MenubarTrigger extends StatefulWidget {
  const MenubarTrigger({super.key, required this.child, this.disabled = false});

  /// The title.
  final Widget child;

  /// Grays it out and keeps its menu shut.
  final bool disabled;

  /// `min-h-7`.
  static const double minHeight = Spacing.d28;

  @override
  State<MenubarTrigger> createState() => _MenubarTriggerState();
}

class _MenubarTriggerState extends State<MenubarTrigger> {
  InkRovingFocusState? _group;
  InkRovingEntry? _entry;
  bool _hovered = false;
  bool _focusVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final menu = MenubarMenuScope.of(context);
    final group = InkRovingFocus.maybeOf(context);
    final entry = _entry;
    if (identical(group, _group) && entry?.focusNode == menu.triggerNode) {
      return;
    }
    if (entry != null) _group?.unregister(entry);
    _group = group;
    final next = InkRovingEntry(menu.triggerNode)..enabled = !widget.disabled;
    _entry = next;
    group?.register(next);
  }

  @override
  void didUpdateWidget(MenubarTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry?.enabled = !widget.disabled;
    _group?.markChanged();
  }

  @override
  void dispose() {
    if (_entry case final entry?) _group?.unregister(entry);
    super.dispose();
  }

  void _toggle(MenubarState bar, MenubarMenuScope menu) {
    if (widget.disabled) return;
    menu.triggerNode.requestFocus();
    bar.setOpen(switch (menu.open) {
      true => null,
      false => menu.id,
    });
  }

  void _openFromKeys(MenubarState bar, MenubarMenuScope menu) {
    if (widget.disabled) return;
    bar.setOpen(menu.id, focusFirst: true);
  }

  void _hover(MenubarState bar, MenubarMenuScope menu) {
    setState(() => _hovered = true);
    final open = bar.openMenu;
    if (widget.disabled || open == null || open == menu.id) return;
    menu.triggerNode.requestFocus();
    bar.setOpen(menu.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final bar = MenubarScope.of(context);
    final menu = MenubarMenuScope.of(context);
    final focused = menu.triggerNode.hasFocus;
    final lit = !widget.disabled && (_hovered || focused || menu.open);
    final calm = theme.density == LooseleafDensity.calm;
    final text = theme.typography.face(
      KevinSansFace.hand,
      cssSize: switch (calm) {
        true => 15,
        false => 16,
      },
      cssLineHeight: 24 / 16,
      fontWeight: FontWeight.w700,
      color: switch ((widget.disabled, lit)) {
        (true, _) => theme.colors.pencilText,
        (false, true) => theme.colors.selectionText,
        (false, false) => theme.colors.ink,
      },
    );
    return Semantics(
      container: true,
      role: SemanticsRole.menuItem,
      enabled: !widget.disabled,
      expanded: menu.open,
      onTap: switch (widget.disabled) {
        true => null,
        false => () => _toggle(bar, menu),
      },
      child: FocusableActionDetector(
        focusNode: menu.triggerNode,
        enabled: !widget.disabled,
        includeFocusSemantics: false,
        onShowFocusHighlight: (visible) =>
            setState(() => _focusVisible = visible),
        onFocusChange: (_) => setState(() {}),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.arrowDown): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _openFromKeys(bar, menu);
              return null;
            },
          ),
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.basic,
          onEnter: (_) => _hover(bar, menu),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: () => _toggle(bar, menu),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: switch (lit) {
                  true => theme.colors.hiSelect,
                  false => null,
                },
                borderRadius: InkMenuMetrics.swipe,
              ),
              position: DecorationPosition.background,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: switch (_focusVisible && !widget.disabled) {
                    true => Border.all(
                      color: theme.colors.focus,
                      width: Spacing.d2,
                    ),
                    false => null,
                  },
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: MenubarTrigger.minHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: switch (calm) {
                        true => Spacing.d10,
                        false => Spacing.d12,
                      },
                      vertical: Spacing.d2,
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: DefaultTextStyle.merge(
                        style: text,
                        softWrap: false,
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
