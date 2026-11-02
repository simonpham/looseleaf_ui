import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DatePickerDateRangeExample extends StatefulWidget {
  const DatePickerDateRangeExample({super.key});

  @override
  State<DatePickerDateRangeExample> createState() =>
      _DatePickerDateRangeExampleState();
}

class _DatePickerDateRangeExampleState
    extends State<DatePickerDateRangeExample> {
  DateRange? _range = DateRange(
    from: DateTime(2026, 9, 9),
    to: DateTime(2026, 9, 24),
  );

  static DateTime _day(int offset) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + offset);
  }

  static DateRange _last7() => DateRange(from: _day(-6), to: _day(0));

  static DateRange _thisMonth() {
    final now = DateTime.now();
    return DateRange(
      from: DateTime(now.year, now.month),
      to: DateTime(now.year, now.month + 1, 0),
    );
  }

  static DateRange _next14() => DateRange(from: _day(0), to: _day(13));

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 320,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        const Label(child: Text('Dates')),
        DateRangePicker(
          value: _range,
          onChanged: (range) => setState(() => _range = range),
          now: () => DateTime(2026, 9, 15),
          semanticLabel: 'Dates',
          presets: const [
            DatePreset(label: 'Last 7 days', value: _last7),
            DatePreset(label: 'This month', value: _thisMonth),
            DatePreset(label: 'Next 14 days', value: _next14),
          ],
        ),
      ],
    ),
  );
}
