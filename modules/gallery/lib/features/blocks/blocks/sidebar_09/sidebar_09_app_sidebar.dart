import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_09/sidebar_09.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The mail pad: a strip of folder icons, always drawn collapsed to icons,
/// and beside it the [Sidebar09MailList] of the folder picked. Collapsed,
/// only the strip stays.
///
/// Mirrors upstream `src/blocks/sidebar-09/components/sidebar-09-app-sidebar.tsx`.
class Sidebar09AppSidebar extends StatelessWidget {
  const Sidebar09AppSidebar({
    super.key,
    required this.folder,
    required this.onFolderChange,
    required this.unread,
    required this.selectedId,
    required this.onSelectMail,
  });

  final MailFolder folder;
  final ValueChanged<MailFolder> onFolderChange;
  final Set<String> unread;
  final String? selectedId;
  final ValueChanged<String> onSelectMail;

  @override
  Widget build(BuildContext context) => Sidebar(
    collapsible: SidebarCollapsible.icon,
    seed: 'sidebar-09',
    children: [
      Expanded(
        child: Builder(
          builder: (context) {
            final panel = SidebarPanelScope.maybeOf(context);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width:
                      SidebarProvider.widgetOf(context)?.widthIcon ??
                      SidebarMetrics.widthIcon,
                  child: SidebarPanelScope(
                    side: panel?.side ?? SidebarSide.left,
                    collapsedToIcons: true,
                    offcanvasCollapsed: false,
                    mobile: panel?.mobile ?? false,
                    child: _Strip(
                      folder: folder,
                      onFolderChange: onFolderChange,
                    ),
                  ),
                ),
                if (!(panel?.collapsedToIcons ?? false))
                  Expanded(
                    child: Sidebar09MailList(
                      folder: folder,
                      unread: unread,
                      selectedId: selectedId,
                      onSelectMail: onSelectMail,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ],
  );
}

class _Strip extends StatelessWidget {
  const _Strip({required this.folder, required this.onFolderChange});

  final MailFolder folder;
  final ValueChanged<MailFolder> onFolderChange;

  @override
  Widget build(BuildContext context) {
    final data = SidebarProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarHeader(
          children: [
            SidebarMenu(
              children: [
                SidebarMenuItem(
                  child: SidebarMenuButton(
                    size: SidebarMenuButtonSize.lg,
                    semanticLabel: 'Looseleaf Studio',
                    onPressed: () {},
                    leading: const BrandTile(icon: 'mail'),
                    child: const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ],
        ),
        SidebarContent(
          children: [
            SidebarGroup(
              children: [
                SidebarGroupContent(
                  child: SidebarMenu(
                    children: [
                      for (final item in MailFolder.values)
                        SidebarMenuItem(
                          child: SidebarMenuButton(
                            tooltip: item.title,
                            isActive: item == folder,
                            onPressed: () {
                              onFolderChange(item);
                              data.setOpen(true);
                            },
                            leading: InkIcon(item.icon),
                            child: Text(item.title),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SidebarFooter(children: [NavUser(user: appUser, iconOnly: true)]),
      ],
    );
  }
}
