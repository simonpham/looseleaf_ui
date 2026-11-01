import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/menubar/menubar.dart';

/// Hands a [Menubar]'s state to its menus.
class MenubarScope extends InheritedWidget {
  const MenubarScope({
    super.key,
    required this.state,
    required this.openMenu,
    required super.child,
  });

  /// The bar.
  final MenubarState state;

  /// The menu that is open, if any.
  final Object? openMenu;

  /// The nearest bar.
  static MenubarState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MenubarScope>();
    if (scope == null) throw FlutterError('No Menubar above this widget.');
    return scope.state;
  }

  @override
  bool updateShouldNotify(MenubarScope oldWidget) =>
      oldWidget.openMenu != openMenu || !identical(oldWidget.state, state);
}

/// What a [MenubarMenu] tells its trigger: its id in the bar, its trigger's
/// focus node and whether it is open.
class MenubarMenuScope extends InheritedWidget {
  const MenubarMenuScope({
    super.key,
    required this.id,
    required this.triggerNode,
    required this.open,
    required super.child,
  });

  /// The menu's id in the bar.
  final Object id;

  /// The trigger's focus node.
  final FocusNode triggerNode;

  /// Whether the menu is open.
  final bool open;

  /// The nearest menu.
  static MenubarMenuScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MenubarMenuScope>();
    if (scope == null) throw FlutterError('No MenubarMenu above this widget.');
    return scope;
  }

  @override
  bool updateShouldNotify(MenubarMenuScope oldWidget) =>
      oldWidget.open != open ||
      oldWidget.id != id ||
      oldWidget.triggerNode != triggerNode;
}
