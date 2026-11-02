import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_10/sidebar_10.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A notes app: favorites and workspaces on the pad, and a page with a
/// star and a menu of page actions in its corner.
///
/// Mirrors upstream `src/blocks/sidebar-10/page.tsx`.
class Sidebar10Block extends StatelessWidget {
  const Sidebar10Block({super.key});

  static const double _height = 640;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      children: [
        Sidebar10AppSidebar(),
        SidebarPageSheet(
          children: [
            SidebarPageHeader(
              crumbs: ['Project plan & to-dos'],
              actions: [Sidebar10NavActions()],
            ),
            SidebarPageBody(
              title: 'Project plan & to-dos',
              kicker: 'Favorites',
              children: [
                SidebarPageNote(
                  title: 'A blank page, for now',
                  pose: 'write',
                  description:
                      'Nothing on this page yet. Open the three dots up in the corner to see what you can do with it.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
