import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_05/sidebar_05.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A docs app whose sections open one at a time, a plus to open and a minus to close.
///
/// Mirrors upstream `src/blocks/sidebar-05/page.tsx`.
class Sidebar05Block extends StatelessWidget {
  const Sidebar05Block({super.key});

  static const double _height = 640;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      children: [
        Sidebar05AppSidebar(),
        SidebarPageSheet(
          children: [
            SidebarPageHeader(crumbs: docsTrail, bordered: true),
            SidebarPageBody(
              title: 'Margins',
              kicker: 'Writing on paper',
              children: [
                SidebarPageNote(
                  title: 'Plus opens, minus closes',
                  pose: 'wave',
                  description:
                      'Open a section on the pad to see its pages. Only one is open to begin with, so the list stays short.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
