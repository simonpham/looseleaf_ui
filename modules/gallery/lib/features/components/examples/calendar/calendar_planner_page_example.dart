import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CalendarPlannerPageExample extends StatefulWidget {
  const CalendarPlannerPageExample({super.key});

  @override
  State<CalendarPlannerPageExample> createState() =>
      _CalendarPlannerPageExampleState();
}

class _CalendarPlannerPageExampleState
    extends State<CalendarPlannerPageExample> {
  DateTime? _date = DateTime(2026, 9, 17);

  @override
  Widget build(BuildContext context) => Calendar(
    selected: _date,
    onSelect: (date) => setState(() => _date = date),
    defaultMonth: DateTime(2026, 9),
    today: DateTime(2026, 9, 15),
    isDateDisabled: (day) => day.isBefore(DateTime(2026, 9, 3)),
    sheet: const CalendarSheet(tape: PaperTape.corner, seed: 'planner'),
    seed: 'planner',
  );
}
