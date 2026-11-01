import 'package:flutter/widgets.dart';

/// Hands an [ItemGroup]'s rules and each member's position to the items in
/// it, like upstream's `InList` context, `data-ruled` and the
/// `group-odd/item` selectors.
class ItemScope extends InheritedWidget {
  const ItemScope({
    super.key,
    required this.ruled,
    required this.index,
    required super.child,
  });

  /// Whether rows get a blue rule underneath.
  final bool ruled;

  /// The member's position in the group, from 0.
  final int index;

  /// The nearest scope; null outside a group.
  static ItemScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ItemScope>();

  @override
  bool updateShouldNotify(ItemScope oldWidget) =>
      oldWidget.ruled != ruled || oldWidget.index != index;
}

/// Tells an [ItemMedia] whether its row has a description, so it moves to
/// the top, like upstream's `group-has-[[data-slot=item-description]]/item`.
class ItemRowScope extends InheritedWidget {
  const ItemRowScope({
    super.key,
    required this.described,
    required super.child,
  });

  /// Whether the row holds an `ItemDescription`.
  final bool described;

  /// Whether the enclosing row has a description.
  static bool describedOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ItemRowScope>()?.described ??
      false;

  @override
  bool updateShouldNotify(ItemRowScope oldWidget) =>
      oldWidget.described != described;
}
