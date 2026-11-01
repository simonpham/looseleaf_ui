import 'package:flutter/foundation.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';

/// What a [SidebarProvider] shares with its parts, upstream's `useSidebar()`:
/// read it with [SidebarProvider.of].
@immutable
class SidebarData {
  const SidebarData({
    required this.open,
    required this.openMobile,
    required this.isMobile,
    required this.setOpen,
    required this.setOpenMobile,
    required this.toggleSidebar,
  });

  /// Whether the desktop sidebar is open.
  final bool open;

  /// Whether the phone sheet is open.
  final bool openMobile;

  /// Whether the window is narrower than the mobile breakpoint, so the
  /// sidebar is a sheet.
  final bool isMobile;

  /// Opens or closes the desktop sidebar.
  final ValueChanged<bool> setOpen;

  /// Opens or closes the phone sheet.
  final ValueChanged<bool> setOpenMobile;

  /// Toggles the sheet on a phone, the sidebar otherwise.
  final VoidCallback toggleSidebar;

  /// `expanded` when [open], `collapsed` otherwise.
  SidebarState get state => switch (open) {
    true => SidebarState.expanded,
    false => SidebarState.collapsed,
  };

  @override
  bool operator ==(Object other) =>
      other is SidebarData &&
      other.open == open &&
      other.openMobile == openMobile &&
      other.isMobile == isMobile;

  @override
  int get hashCode => Object.hash(open, openMobile, isMobile);
}
