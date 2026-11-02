import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/calendar/calendar.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CalendarBookACallExample extends StatefulWidget {
  const CalendarBookACallExample({super.key});

  @override
  State<CalendarBookACallExample> createState() =>
      _CalendarBookACallExampleState();
}

class _CalendarBookACallExampleState extends State<CalendarBookACallExample> {
  static const _slots = [
    '09:00',
    '09:30',
    '10:30',
    '11:00',
    '13:30',
    '14:00',
    '15:30',
    '16:00',
  ];
  static const _slotsWidth = 144.0;

  DateTime? _date = DateTime(2026, 9, 17);
  String? _slot = '10:30';

  static bool _closed(DateTime day) =>
      day.weekday == DateTime.saturday ||
      day.weekday == DateTime.sunday ||
      day.isBefore(DateTime(2026, 9, 15));

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return IntrinsicWidth(
      child: Card(
        seed: 'book',
        tape: PaperTape.top,
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Book a call')),
              CardDescription(
                Text('Thirty minutes, on the phone or in the studio.'),
              ),
            ],
          ),
          CardContent(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                Calendar(
                  selected: _date,
                  onSelect: (date) => setState(() {
                    _date = date;
                    _slot = null;
                  }),
                  defaultMonth: DateTime(2026, 9),
                  today: DateTime(2026, 9, 15),
                  isDateDisabled: _closed,
                  padding: EdgeInsets.zero,
                  seed: 'book',
                ),
                Semantics(
                  container: true,
                  label: 'Available times',
                  child: SizedBox(
                    width: _slotsWidth,
                    child: Wrap(
                      spacing: Spacing.d8,
                      runSpacing: Spacing.d8,
                      children: [
                        for (final time in _slots)
                          SizedBox(
                            width: (_slotsWidth - Spacing.d8) / 2,
                            child: Semantics(
                              toggled: _slot == time,
                              child: Button(
                                size: ButtonSize.sm,
                                variant: switch (_slot == time) {
                                  true => ButtonVariant.primary,
                                  false => ButtonVariant.outline,
                                },
                                disabled: _date == null,
                                onPressed: () => setState(() => _slot = time),
                                child: Text(time),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          CardFooter(
            divider: true,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: Spacing.d12,
            children: [
              Flexible(
                child: Text(
                  switch ((_date, _slot)) {
                    (final date?, final slot?) =>
                      '${calendarDateString(date)} at $slot',
                    _ => 'Choose a day and a time.',
                  },
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ),
              Button(
                disabled: _date == null || _slot == null,
                onPressed: () {},
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
