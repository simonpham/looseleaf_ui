import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_12/sidebar_12.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A calendar app: pick a day in the month on the pad and the page shows
/// it; tick the calendars you want to see.
///
/// Mirrors upstream `src/blocks/sidebar-12/page.tsx`.
class Sidebar12Block extends StatefulWidget {
  const Sidebar12Block({super.key});

  @override
  State<Sidebar12Block> createState() => _Sidebar12BlockState();
}

class _Sidebar12BlockState extends State<Sidebar12Block> {
  DateTime _date = DateTime(2026, 9, 25);
  List<String> _visible = defaultVisibleCalendars;

  static const double _height = 700;

  @override
  Widget build(BuildContext context) {
    final all = calendarGroups.expand((group) => group.items).length;
    return SizedBox(
      height: _height,
      child: SidebarProvider(
        children: [
          Sidebar12AppSidebar(
            date: _date,
            onDateChange: (date) => setState(() => _date = date),
            visible: _visible,
            onVisibleChange: (next) => setState(() => _visible = next),
          ),
          SidebarPageSheet(
            children: [
              SidebarPageHeader(
                crumbs: [formatPlannerMonth(_date)],
                bordered: true,
              ),
              SidebarPageBody(
                title: formatPlannerDay(_date),
                kicker: 'Calendar',
                children: [
                  SidebarPageNote(
                    title: 'A quiet day',
                    pose: 'sleep',
                    description:
                        'Nothing pencilled in. Showing ${_visible.length} of $all calendars, so it may be busier elsewhere.',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
