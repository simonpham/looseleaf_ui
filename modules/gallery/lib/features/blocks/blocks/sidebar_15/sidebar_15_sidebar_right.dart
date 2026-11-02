import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The week pad on the right, taped down and never collapsing: the
/// account, a month to pick a day from, the calendars and a row to add
/// one. Only on wide windows.
///
/// Mirrors upstream `src/blocks/sidebar-15/components/sidebar-15-sidebar-right.tsx`.
class Sidebar15SidebarRight extends StatelessWidget {
  const Sidebar15SidebarRight({
    super.key,
    required this.date,
    required this.onDateChange,
    required this.visible,
    required this.onVisibleChange,
  });

  final DateTime date;
  final ValueChanged<DateTime> onDateChange;
  final List<String> visible;
  final ValueChanged<List<String>> onVisibleChange;

  /// Tailwind's `lg`.
  static const double largeWidth = 1024;
  static const double _tapeLength = 72;
  static const double _tapeHeight = 18;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < largeWidth) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Separator(orientation: SeparatorOrientation.vertical),
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: Spacing.d12),
              child: Sidebar(
                collapsible: SidebarCollapsible.none,
                side: SidebarSide.right,
                seed: 'sidebar-15-right',
                children: [
                  const SizedBox(
                    height: Spacing.d64,
                    child: SidebarHeader(
                      children: [
                        NavUser(user: appUser, align: OverlayAlign.start),
                      ],
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
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Tape(
                  kind: TapeKind.washiStripes,
                  color: Accent.tangerine,
                  length: _tapeLength,
                  height: _tapeHeight,
                  angle: -2,
                  seed: 'sidebar-15-tape',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
