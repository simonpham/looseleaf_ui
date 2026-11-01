import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/navigation_menu/navigation_menu.dart';

/// Hands a [NavigationMenuController] down to the menu's parts and rebuilds
/// them when it changes.
class NavigationMenuScope extends InheritedNotifier<NavigationMenuController> {
  const NavigationMenuScope({
    super.key,
    required NavigationMenuController controller,
    required super.child,
  }) : super(notifier: controller);
}

/// Marks the inside of a panel: a [NavigationMenuLink] there is a row, not
/// a tab.
class NavigationMenuPanelScope extends InheritedWidget {
  const NavigationMenuPanelScope({super.key, required super.child});

  /// Whether [context] is inside a panel.
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NavigationMenuPanelScope>() !=
      null;

  @override
  bool updateShouldNotify(NavigationMenuPanelScope oldWidget) => false;
}

/// Tells an item's parts which item they belong to.
class NavigationMenuItemScope extends InheritedWidget {
  const NavigationMenuItemScope({
    super.key,
    required this.value,
    required super.child,
  });

  /// The item's value.
  final String value;

  /// The enclosing item's value, or null.
  static String? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<NavigationMenuItemScope>()
      ?.value;

  @override
  bool updateShouldNotify(NavigationMenuItemScope oldWidget) =>
      oldWidget.value != value;
}
