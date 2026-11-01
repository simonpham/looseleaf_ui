import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';

/// Tells a [Sidebar]'s parts how the pad they sit on is laid out: upstream's
/// `group-data-[collapsible=icon]`, `data-side` and `data-mobile`.
class SidebarPanelScope extends InheritedWidget {
  const SidebarPanelScope({
    super.key,
    required this.side,
    required this.collapsedToIcons,
    required this.offcanvasCollapsed,
    required this.mobile,
    required super.child,
  });

  /// The edge the pad hangs on.
  final SidebarSide side;

  /// Collapsed to a column of icons: labels hide, rows are squares.
  final bool collapsedToIcons;

  /// Slid off the screen.
  final bool offcanvasCollapsed;

  /// In the phone sheet.
  final bool mobile;

  /// The nearest scope; an expanded left pad when there is none.
  static SidebarPanelScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SidebarPanelScope>();

  /// Whether the pad around [context] is collapsed to icons.
  static bool iconsOf(BuildContext context) =>
      maybeOf(context)?.collapsedToIcons ?? false;

  @override
  bool updateShouldNotify(SidebarPanelScope oldWidget) =>
      oldWidget.side != side ||
      oldWidget.collapsedToIcons != collapsedToIcons ||
      oldWidget.offcanvasCollapsed != offcanvasCollapsed ||
      oldWidget.mobile != mobile;
}
