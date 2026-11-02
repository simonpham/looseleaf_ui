import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_15/sidebar_15.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A notes app with two pads: notes on the left, the week on the right
/// (on wide windows); the day picked there names the page.
///
/// Mirrors upstream `src/blocks/sidebar-15/page.tsx`.
class Sidebar15Block extends StatefulWidget {
  const Sidebar15Block({super.key});

  @override
  State<Sidebar15Block> createState() => _Sidebar15BlockState();
}

class _Sidebar15BlockState extends State<Sidebar15Block> {
  DateTime _date = DateTime(2026, 9, 25);
  List<String> _visible = defaultVisibleCalendars;

  static const double _height = 700;

  @override
  Widget build(BuildContext context) {
    final wide =
        MediaQuery.sizeOf(context).width >= Sidebar15SidebarRight.largeWidth;
    return SizedBox(
      height: _height,
      child: SidebarProvider(
        children: [
          const Sidebar15SidebarLeft(),
          SidebarPageSheet(
            children: [
              const SidebarPageHeader(crumbs: ['Project plan & to-dos']),
              SidebarPageBody(
                title: 'Project plan & to-dos',
                kicker: formatPlannerDay(_date),
                children: [
                  SidebarPageNote(
                    title: 'Two pads, one page',
                    pose: 'carry',
                    description: switch (wide) {
                      true =>
                        'Notes on the left, your week on the right. Pick a day in the month and the kicker above follows.',
                      false =>
                        'Notes on the left, your week on the right. Widen the window and the week pad opens.',
                    },
                  ),
                ],
              ),
            ],
          ),
          Sidebar15SidebarRight(
            date: _date,
            onDateChange: (date) => setState(() => _date = date),
            visible: _visible,
            onVisibleChange: (next) => setState(() => _visible = next),
          ),
        ],
      ),
    );
  }
}
