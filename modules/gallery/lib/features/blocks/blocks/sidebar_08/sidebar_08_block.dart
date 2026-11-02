import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_08/sidebar_08.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A studio app with an inset pad: the page is a sheet of its own, set
/// down on the desk beside it.
///
/// Mirrors upstream `src/blocks/sidebar-08/page.tsx`.
class Sidebar08Block extends StatelessWidget {
  const Sidebar08Block({super.key});

  static const double _height = 640;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      children: [
        Sidebar08AppSidebar(),
        SidebarPageSheet(
          variant: SidebarVariant.inset,
          children: [
            SidebarPageHeader(crumbs: ['Sketchbook', 'Recent']),
            SidebarPageBody(
              title: 'Recent sketches',
              kicker: 'Sketchbook',
              children: [
                SidebarPageNote(
                  title: 'Two sheets on the desk',
                  pose: 'search',
                  description: 'The pad keeps its distance and the page rests beside it; on a phone the pad slides in over it. Fold a row open to look inside.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
