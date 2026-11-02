import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_04/sidebar_04.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A docs app with a floating pad set down on the desk beside a page that rests on its own.
///
/// Mirrors upstream `src/blocks/sidebar-04/page.tsx`.
class Sidebar04Block extends StatelessWidget {
  const Sidebar04Block({super.key});

  static const double _height = 640;

  /// `--sidebar-width: 19rem`.
  static const double sidebarWidth = 304;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      width: Sidebar04Block.sidebarWidth,
      children: [
        Sidebar04AppSidebar(),
        SidebarPageSheet(
          variant: SidebarVariant.floating,
          children: [
            SidebarPageHeader(crumbs: docsTrail),
            SidebarPageBody(
              title: 'Margins',
              kicker: 'Writing on paper',
              children: [
                SidebarPageNote(
                  title: 'Two sheets on one desk',
                  pose: 'sketch',
                  description:
                      'The pad floats, the page rests. Nothing is stuck down. On a phone the pad slides in over the page instead.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
