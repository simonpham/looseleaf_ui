import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_06/sidebar_06.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The field guide's pad: sections that drop menus of their pages, and a
/// postcard sign-up at its foot (left out when the window is short).
///
/// Mirrors upstream `src/blocks/sidebar-06/components/sidebar-06-app-sidebar.tsx`.
class Sidebar06AppSidebar extends StatelessWidget {
  const Sidebar06AppSidebar({super.key});

  /// `[@media(max-height:34rem)]:hidden`.
  static const double _shortWindow = 544;

  @override
  Widget build(BuildContext context) => Sidebar(
    seed: 'sidebar-06',
    rail: const SidebarRail(),
    children: [
      const SidebarHeader(
        children: [
          SidebarBrand(
            title: 'Field guide',
            subtitle: 'v1.0.0',
            icon: 'book-open',
          ),
        ],
      ),
      const SidebarContent(children: [Sidebar06NavMain(items: docsNav)]),
      if (MediaQuery.sizeOf(context).height > _shortWindow)
        const SidebarFooter(
          children: [
            Padding(
              padding: EdgeInsets.all(Spacing.d4),
              child: Sidebar06OptInForm(),
            ),
          ],
        ),
    ],
  );
}
