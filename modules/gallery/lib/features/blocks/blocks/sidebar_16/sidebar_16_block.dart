import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_16/sidebar_16.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A studio app with a header across the whole window and the pad below
/// it, beside the page.
///
/// Mirrors upstream `src/blocks/sidebar-16/page.tsx`.
class Sidebar16Block extends StatelessWidget {
  const Sidebar16Block({super.key});

  static const double _height = 640;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      header: Sidebar16SiteHeader(),
      children: [
        Sidebar16AppSidebar(),
        SidebarPageSheet(
          children: [
            SidebarPageBody(
              title: 'Margins',
              kicker: 'Writing on paper',
              children: [
                SidebarPageNote(
                  title: 'Header on top, pad below',
                  pose: 'wave',
                  description: 'The strip across the top belongs to the whole window, so the search box is always in reach, wherever you have scrolled to.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
