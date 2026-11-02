import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_01/sidebar_01.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A docs app: the field guide's pad grouped by section beside an empty
/// page with a breadcrumb trail.
///
/// Mirrors upstream `src/blocks/sidebar-01/page.tsx`.
class Sidebar01Block extends StatelessWidget {
  const Sidebar01Block({super.key});

  static const double _height = 640;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      children: [
        Sidebar01AppSidebar(),
        SidebarPageSheet(
          children: [
            SidebarPageHeader(crumbs: docsTrail, bordered: true),
            SidebarPageBody(
              title: 'Margins',
              kicker: 'Writing on paper',
              children: [
                SidebarPageNote(
                  title: 'The margin is empty',
                  pose: 'write',
                  description: 'Nothing scribbled here yet. Pick another page from the pad, or grab a pencil and start one.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
