import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A month on the pad to pick a day from.
///
/// Upstream shrinks the day cells to 32 px (`[--cell:2rem]`); [Calendar]
/// has no cell size, so the month is scaled down to the pad's width.
///
/// Mirrors `DatePicker` in upstream
/// `src/blocks/sidebar-shared/sidebar-calendar.tsx`.
class SidebarDatePicker extends StatelessWidget {
  const SidebarDatePicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Calendar(
        selected: selected,
        defaultMonth: selected,
        padding: EdgeInsets.zero,
        onSelect: (picked) {
          if (picked != null) onSelect(picked);
        },
      ),
    ),
  );
}
