import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_06/sidebar_06.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A docs app whose sections open as small menus of their pages, with a postcard sign-up at the foot of the pad.
///
/// Mirrors upstream `src/blocks/sidebar-06/page.tsx`.
class Sidebar06Block extends StatelessWidget {
  const Sidebar06Block({super.key});

  static const double _height = 640;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      children: [
        Sidebar06AppSidebar(),
        SidebarPageSheet(
          children: [
            SidebarPageHeader(crumbs: docsTrail, bordered: true),
            SidebarPageBody(
              title: 'Margins',
              kicker: 'Writing on paper',
              children: [
                SidebarPageNote(
                  title: 'Pick a section',
                  pose: 'point',
                  description:
                      'Each heading on the pad opens a small menu of its pages. Choose one and it lands here.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
