import 'package:flutter/widgets.dart';

/// A row's place in its [SidebarMenu], for the odd and even ruling.
class SidebarMenuItemIndex extends InheritedWidget {
  const SidebarMenuItemIndex({
    super.key,
    required this.index,
    required super.child,
  });

  /// Zero-based: CSS's first, odd, row is 0.
  final int index;

  /// Whether the row around [context] is an odd row (`:nth-child(odd)`).
  static bool oddOf(BuildContext context) =>
      (context
                  .dependOnInheritedWidgetOfExactType<SidebarMenuItemIndex>()
                  ?.index ??
              0)
          .isEven;

  @override
  bool updateShouldNotify(SidebarMenuItemIndex oldWidget) =>
      oldWidget.index != index;
}
