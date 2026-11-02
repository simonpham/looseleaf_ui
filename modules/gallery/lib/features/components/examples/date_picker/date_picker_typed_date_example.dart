import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DatePickerTypedDateExample extends StatefulWidget {
  const DatePickerTypedDateExample({super.key});

  @override
  State<DatePickerTypedDateExample> createState() =>
      _DatePickerTypedDateExampleState();
}

class _DatePickerTypedDateExampleState
    extends State<DatePickerTypedDateExample> {
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  DateTime? _date = DateTime(2026, 9, 17);

  static String _dateString(DateTime date) =>
      '${_weekdays[date.weekday - 1]} ${_months[date.month - 1]} '
      '${date.day.toString().padLeft(2, '0')} ${date.year}';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      width: 288,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d8,
        children: [
          const Label(child: Text('Due date')),
          DatePicker(
            value: _date,
            onChanged: (date) => setState(() => _date = date),
            min: DateTime(2026, 9, 3),
            now: () => DateTime(2026, 9, 15),
            semanticLabel: 'Due date',
          ),
          Text(
            switch (_date) {
              final date? => _dateString(date),
              null => 'No date yet.',
            },
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
