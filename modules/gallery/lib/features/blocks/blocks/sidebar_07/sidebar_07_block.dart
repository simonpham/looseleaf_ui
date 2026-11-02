import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_07/sidebar_07.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A studio app whose pad squeezes down to a column of icons; the header
/// gets shorter with it.
///
/// Mirrors upstream `src/blocks/sidebar-07/page.tsx`.
class Sidebar07Block extends StatelessWidget {
  const Sidebar07Block({super.key});

  static const double _height = 640;

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: _height,
    child: SidebarProvider(
      children: [
        Sidebar07AppSidebar(),
        SidebarPageSheet(
          children: [
            _Header(),
            SidebarPageBody(
              title: 'Recent sketches',
              kicker: 'Sketchbook',
              children: [
                SidebarPageNote(
                  title: 'Nothing sketched today',
                  pose: 'sketch',
                  description: 'The button above squeezes the pad down to icons so the page gets all the room. On a phone it opens the pad instead.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final data = SidebarProvider.of(context);
    final collapsed = !data.open && !data.isMobile;
    return TweenAnimationBuilder<double>(
      tween: Tween(
        end: switch (collapsed) {
          true => Spacing.d48,
          false => Spacing.d64,
        },
      ),
      duration: InkMotion.of(context, InkMotion.sheet),
      builder: (context, height, _) => SidebarPageHeader(
        crumbs: const ['Sketchbook', 'Recent'],
        height: height,
      ),
    );
  }
}
