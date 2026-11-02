import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DatePickerPresetsExample extends StatefulWidget {
  const DatePickerPresetsExample({super.key});

  @override
  State<DatePickerPresetsExample> createState() =>
      _DatePickerPresetsExampleState();
}

class _DatePickerPresetsExampleState extends State<DatePickerPresetsExample> {
  DateTime? _date;

  static DateTime _today() => DateTime.now();

  static DateTime _tomorrow() => _inDays(1);

  static DateTime _inAWeek() => _inDays(7);

  static DateTime _nextMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, now.day);
  }

  static DateTime _inDays(int days) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + days);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: Spacing.d288,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        const Label(child: Text('Remind me')),
        DatePicker(
          value: _date,
          onChanged: (date) => setState(() => _date = date),
          placeholder: 'Pick a day',
          semanticLabel: 'Remind me',
          presets: const [
            DatePreset(label: 'Today', value: _today),
            DatePreset(label: 'Tomorrow', value: _tomorrow),
            DatePreset(label: 'In a week', value: _inAWeek),
            DatePreset(label: 'Next month', value: _nextMonth),
          ],
        ),
      ],
    ),
  );
}
