import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DatePickerButtonFieldExample extends StatefulWidget {
  const DatePickerButtonFieldExample({super.key});

  @override
  State<DatePickerButtonFieldExample> createState() =>
      _DatePickerButtonFieldExampleState();
}

class _DatePickerButtonFieldExampleState
    extends State<DatePickerButtonFieldExample> {
  DateTime? _born;
  DateTime? _ship = DateTime(2026, 9, 30);

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: Spacing.d288,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          _Field(
            label: 'Date of birth',
            child: DatePicker(
              typeable: false,
              value: _born,
              onChanged: (date) => setState(() => _born = date),
              placeholder: 'Pick your birthday',
              max: DateTime(2026, 9, 15),
              semanticLabel: 'Date of birth',
              calendarBuilder: (context, selected, onSelect, isDisabled) =>
                  Calendar(
                    selected: selected,
                    onSelect: onSelect,
                    isDateDisabled: isDisabled,
                    captionLayout: CalendarCaptionLayout.dropdown,
                    startMonth: DateTime(1930),
                    endMonth: DateTime(2026, 9),
                    defaultMonth: selected ?? DateTime(1990, 6),
                    today: DateTime(2026, 9, 15),
                    autofocus: true,
                  ),
            ),
          ),
          _Field(
            label: 'Ship by',
            child: DatePicker(
              typeable: false,
              invalid: true,
              value: _ship,
              onChanged: (date) => setState(() => _ship = date),
              semanticLabel: 'Ship by',
            ),
          ),
          _Field(
            label: 'Closed on',
            child: DatePicker(
              disabled: true,
              value: DateTime(2026, 12, 25),
              semanticLabel: 'Closed on',
            ),
          ),
        ],
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d8,
    children: [
      Label(child: Text(label)),
      child,
    ],
  );
}
