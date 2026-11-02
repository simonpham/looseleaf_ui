import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_02/sidebar_02.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A docs app whose pad folds every section shut from its heading.
///
/// Mirrors upstream `src/blocks/sidebar-02/page.tsx`.
class Sidebar02Block extends StatelessWidget {
  const Sidebar02Block({super.key});

  static const double _height = 640;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      children: [
        Sidebar02AppSidebar(),
        SidebarPageSheet(
          children: [
            SidebarPageHeader(crumbs: docsTrail, bordered: true),
            SidebarPageBody(
              title: 'Margins',
              kicker: 'Writing on paper',
              children: [
                SidebarPageNote(
                  title: 'Fold what you are not reading',
                  pose: 'think',
                  description: 'Every heading on the pad folds shut. Tidy the shelf, and the page you want is one glance away.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
