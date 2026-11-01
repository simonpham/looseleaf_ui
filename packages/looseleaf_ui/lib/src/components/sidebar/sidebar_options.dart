/// Which edge of the screen the sidebar hangs on.
enum SidebarSide { left, right }

/// How the sidebar sits beside the page.
enum SidebarVariant {
  /// Docked to the edge, casting its shadow toward the page.
  sidebar,

  /// Set down on the desk, a little turned, with room around it.
  floating,

  /// Room around the pad, and the [SidebarVariant.inset] page becomes a
  /// sheet of paper.
  inset,
}

/// What collapsing does.
enum SidebarCollapsible {
  /// Slides off the screen.
  offcanvas,

  /// Shrinks to a column of icons.
  icon,

  /// Never collapses.
  none,
}

/// Upstream's `state`: whether the desktop sidebar is open.
enum SidebarState { expanded, collapsed }

/// A [SidebarMenuButton]'s look.
enum SidebarMenuButtonVariant {
  /// Plain row.
  regular,

  /// Row with a pencil box.
  outline,
}

/// A [SidebarMenuButton]'s height: 32, 28 or 48 px.
enum SidebarMenuButtonSize { regular, sm, lg }

/// A [SidebarMenuSubButton]'s text: 16 or 15 px.
enum SidebarMenuSubButtonSize { md, sm }
