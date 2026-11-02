import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_03/sidebar_03.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A docs app with the pad laid out as an outline: bold sections, their pages indented under a pencil line.
///
/// Mirrors upstream `src/blocks/sidebar-03/page.tsx`.
class Sidebar03Block extends StatelessWidget {
  const Sidebar03Block({super.key});

  static const double _height = 640;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      children: [
        Sidebar03AppSidebar(),
        SidebarPageSheet(
          children: [
            SidebarPageHeader(crumbs: docsTrail, bordered: true),
            SidebarPageBody(
              title: 'Margins',
              kicker: 'Writing on paper',
              children: [
                SidebarPageNote(
                  title: 'Nothing here yet',
                  pose: 'peek',
                  description: 'This page is still blank. The pad has every page, indented the way an outline is.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
