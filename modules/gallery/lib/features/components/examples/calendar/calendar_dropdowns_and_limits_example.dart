import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/calendar/calendar.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CalendarDropdownsAndLimitsExample extends StatefulWidget {
  const CalendarDropdownsAndLimitsExample({super.key});

  @override
  State<CalendarDropdownsAndLimitsExample> createState() =>
      _CalendarDropdownsAndLimitsExampleState();
}

class _CalendarDropdownsAndLimitsExampleState
    extends State<CalendarDropdownsAndLimitsExample> {
  DateTime? _date;

  static bool _closed(DateTime day) =>
      day.weekday == DateTime.saturday ||
      day.weekday == DateTime.sunday ||
      day.isBefore(DateTime(2026, 9, 15));

  @override
  Widget build(BuildContext context) => Calendar(
    captionLayout: CalendarCaptionLayout.dropdown,
    selected: _date,
    onSelect: (date) => setState(() => _date = date),
    defaultMonth: DateTime(2026, 9),
    startMonth: DateTime(2024),
    endMonth: DateTime(2028, 12),
    today: DateTime(2026, 9, 15),
    isDateDisabled: _closed,
    sheet: const CalendarSheet(),
    seed: 'limits',
    footer: Text(switch (_date) {
      final date? => 'You picked ${calendarDateString(date)}.',
      null => 'Pick a weekday from the 15th on.',
    }),
  );
}
