import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_14/sidebar_14.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A docs page with its table of contents on a pad on the right, folded
/// away from the button at the header's end.
///
/// Mirrors upstream `src/blocks/sidebar-14/page.tsx`.
class Sidebar14Block extends StatelessWidget {
  const Sidebar14Block({super.key});

  static const double _height = 640;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      children: [
        SidebarPageSheet(
          children: [
            SidebarPageHeader(
              crumbs: docsTrail,
              trigger: PageTriggerSide.end,
              bordered: true,
            ),
            SidebarPageBody(
              title: 'Margins',
              kicker: 'Writing on paper',
              children: [
                SidebarPageNote(
                  title: 'Read it from the right',
                  pose: 'peek',
                  description:
                      'The pad on this side lists what is on the page. Fold it away with the button in the corner when you would rather just read.',
                ),
              ],
            ),
          ],
        ),
        Sidebar14AppSidebar(),
      ],
    ),
  );
}
