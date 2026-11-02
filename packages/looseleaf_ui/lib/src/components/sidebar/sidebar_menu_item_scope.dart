import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';

/// What a [SidebarMenuItem] tells its button, action and badge: upstream's
/// `group/menu-item` and `peer/menu-button` selectors.
class SidebarMenuItemScope extends InheritedWidget {
  const SidebarMenuItemScope({
    super.key,
    required this.hasAction,
    this.hasBadge = false,
    required this.buttonSize,
    required this.engaged,
    required super.child,
  });

  /// The row has a [SidebarMenuAction]: its button leaves room at the end.
  final bool hasAction;

  /// The row has a [SidebarMenuBadge]: its button leaves room at the end
  /// too (upstream's `group-has-data-[sidebar=menu-badge]/menu-item:pe-8`).
  final bool hasBadge;

  /// The row button's size, reported by the button.
  final ValueNotifier<SidebarMenuButtonSize> buttonSize;

  /// The row is hovered or holds focus.
  final ValueListenable<bool> engaged;

  /// The nearest scope, or null outside a row.
  static SidebarMenuItemScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SidebarMenuItemScope>();

  @override
  bool updateShouldNotify(SidebarMenuItemScope oldWidget) =>
      oldWidget.hasAction != hasAction ||
      oldWidget.hasBadge != hasBadge ||
      oldWidget.buttonSize != buttonSize ||
      oldWidget.engaged != engaged;
}
