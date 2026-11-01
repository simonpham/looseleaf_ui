import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/components/menubar/menubar.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One menu of a [Menubar]: its [trigger] (a [MenubarTrigger]) on the
/// strip and its [content] (a [MenubarContent]), which drops 8 px below
/// the title, lined up with its start, at least 192 px wide.
///
/// Mirrors `MenubarMenu` in upstream `src/components/ui/menubar.tsx`.
class MenubarMenu extends StatefulWidget {
  const MenubarMenu({
    super.key,
    required this.trigger,
    required this.content,
    this.value,
  });

  /// The title on the strip.
  final Widget trigger;

  /// The menu's slip.
  final MenubarContent content;

  /// Names the menu for [Menubar.value].
  final String? value;

  /// Upstream's `MenubarContent` placement.
  static const InkMenuPlacement placement = InkMenuPlacement(
    align: OverlayAlign.start,
    alignOffset: -Spacing.d4,
    sideOffset: Spacing.d8,
    minWidth: _minWidth,
  );

  /// `min-w-48`.
  static const double _minWidth = 192;

  @override
  State<MenubarMenu> createState() => _MenubarMenuState();
}

class _MenubarMenuState extends State<MenubarMenu> {
  final FocusNode _trigger = FocusNode(debugLabel: 'MenubarTrigger');
  late final Object _ownId = Object();
  MenubarState? _bar;

  Object get _id => widget.value ?? _ownId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bar = MenubarScope.of(context);
    if (identical(bar, _bar)) return;
    _bar?.unregister(_id);
    _bar = bar;
    bar.register(_id, _trigger);
  }

  @override
  void dispose() {
    _bar?.unregister(_id);
    _trigger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bar = MenubarScope.of(context);
    final open = bar.openMenu == _id;
    return MenubarMenuScope(
      id: _id,
      triggerNode: _trigger,
      open: open,
      child: InkMenuPopup(
        open: open,
        onOpenChange: (value) {
          if (value) {
            bar.setOpen(_id);
            return;
          }
          if (bar.openMenu == _id) bar.setOpen(null);
        },
        content: widget.content,
        groupId: bar.groupId,
        modal: false,
        focusFirst: bar.focusFirst,
        placement: MenubarMenu.placement,
        onArrowOut: (step) => bar.step(_id, step),
        child: widget.trigger,
      ),
    );
  }
}
