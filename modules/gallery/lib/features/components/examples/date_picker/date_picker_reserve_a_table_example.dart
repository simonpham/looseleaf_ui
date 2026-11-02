import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DatePickerReserveATableExample extends StatefulWidget {
  const DatePickerReserveATableExample({super.key});

  @override
  State<DatePickerReserveATableExample> createState() =>
      _DatePickerReserveATableExampleState();
}

class _DatePickerReserveATableExampleState
    extends State<DatePickerReserveATableExample> {
  static const _times = ['18:00', '19:00', '20:00', '21:00'];

  DateTime? _date;
  String _time = '19:00';
  String? _sent;

  static String _isoDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  void _reserve() {
    final day = switch (_date) {
      final date? => _isoDate(date),
      null => 'no date',
    };
    setState(() => _sent = '$day at $_time');
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Card(
        seed: 'reserve',
        tape: PaperTape.corner,
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Reserve a table')),
              CardDescription(Text('We are closed on Mondays.')),
            ],
          ),
          CardContent(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d8,
                    children: [
                      const Label(required: true, child: Text('Day')),
                      DatePicker(
                        value: _date,
                        onChanged: (date) => setState(() => _date = date),
                        min: DateTime(2026, 9, 15),
                        isDateDisabled: (day) => day.weekday == DateTime.monday,
                        now: () => DateTime(2026, 9, 15),
                        semanticLabel: 'Day',
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d8,
                    children: [
                      const Label(child: Text('Time')),
                      Select(
                        value: _time,
                        onChanged: (time) => setState(() => _time = time),
                        content: SelectContent(
                          position: SelectPosition.popper,
                          children: [
                            for (final time in _times)
                              SelectItem(value: time, child: Text(time)),
                          ],
                        ),
                        child: const SelectTrigger(semanticLabel: 'Time'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          CardFooter(
            divider: true,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: Spacing.d12,
            children: [
              Flexible(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    switch (_sent) {
                      final sent? => 'Sent: $sent',
                      null => 'Nothing sent yet.',
                    },
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
              Button(onPressed: _reserve, child: const Text('Reserve')),
            ],
          ),
        ],
      ),
    );
  }
}
