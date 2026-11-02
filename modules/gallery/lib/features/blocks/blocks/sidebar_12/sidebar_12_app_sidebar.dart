import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The calendar pad: the account on top, a month to pick a day from, the
/// calendars to show, and a row to add one.
///
/// Mirrors upstream `src/blocks/sidebar-12/components/sidebar-12-app-sidebar.tsx`.
class Sidebar12AppSidebar extends StatelessWidget {
  const Sidebar12AppSidebar({
    super.key,
    required this.date,
    required this.onDateChange,
    required this.visible,
    required this.onVisibleChange,
  });

  final DateTime date;
  final ValueChanged<DateTime> onDateChange;

  /// The calendars shown.
  final List<String> visible;
  final ValueChanged<List<String>> onVisibleChange;

  @override
  Widget build(BuildContext context) => Sidebar(
    seed: 'sidebar-12',
    rail: const SidebarRail(),
    children: [
      const SizedBox(
        height: Spacing.d64,
        child: SidebarHeader(
          children: [NavUser(user: appUser, align: OverlayAlign.start)],
        ),
      ),
      const Separator(),
      SidebarContent(
        children: [
          SidebarDatePicker(selected: date, onSelect: onDateChange),
          const Separator(),
          SidebarCalendars(
            groups: calendarGroups,
            value: visible,
            onValueChange: onVisibleChange,
          ),
        ],
      ),
      SidebarFooter(
        children: [
          SidebarMenu(
            children: [
              SidebarMenuItem(
                child: SidebarMenuButton(
                  onPressed: () {},
                  leading: const InkIcon('plus'),
                  child: const Text('New calendar'),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
