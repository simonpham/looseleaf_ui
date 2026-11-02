import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A month on the pad to pick a day from, its day cells 32 px (30 px
/// compact) to fit the pad.
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
  Widget build(BuildContext context) => SidebarGroup(
    padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
    children: [
      SidebarGroupContent(
        child: Center(
          child: Calendar(
            selected: selected,
            defaultMonth: selected,
            padding: EdgeInsets.zero,
            cellSize: switch (LooseleafTheme.of(context).density) {
              LooseleafDensity.compact => Spacing.d30,
              _ => Spacing.d32,
            },
            onSelect: (picked) {
              if (picked != null) onSelect(picked);
            },
          ),
        ),
      ),
    ],
  );
}
