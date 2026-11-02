import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CalendarRangeTwoMonthsExample extends StatefulWidget {
  const CalendarRangeTwoMonthsExample({super.key});

  @override
  State<CalendarRangeTwoMonthsExample> createState() =>
      _CalendarRangeTwoMonthsExampleState();
}

class _CalendarRangeTwoMonthsExampleState
    extends State<CalendarRangeTwoMonthsExample> {
  DateRange? _range = DateRange(
    from: DateTime(2026, 9, 24),
    to: DateTime(2026, 10, 6),
  );

  @override
  Widget build(BuildContext context) => Calendar.range(
    numberOfMonths: 2,
    showWeekNumber: true,
    selected: _range,
    onSelect: (range) => setState(() => _range = range),
    defaultMonth: DateTime(2026, 9),
    today: DateTime(2026, 9, 15),
    sheet: const CalendarSheet(
      stock: StockName.paper,
      fastener: FastenerKind.binderClip,
      tiltDegrees: 0.4,
    ),
    seed: 'range',
  );
}
