import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/calendar_planner/calendar_planner.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The chosen day on an index card: its events by the clock, or a free
/// day.
///
/// Mirrors `DayCard` in upstream
/// `src/blocks/calendar-planner/components/calendar-planner-agenda.tsx`.
class CalendarPlannerDayCard extends StatelessWidget {
  const CalendarPlannerDayCard({
    super.key,
    required this.day,
    required this.list,
    required this.onOpen,
  });

  final String day;
  final List<CalendarPlannerEvent> list;
  final ValueChanged<CalendarPlannerEvent> onOpen;

  static const _numberWords = [
    'no',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final events = calendarPlannerOnDay(list, day);
    return IndexCard(
      seed: 'planner-day-$day',
      tilt: false,
      maxWidth: double.infinity,
      children: [
        IndexCardHeader(
          children: [
            IndexCardTitle(Text(calendarPlannerLongDay(day))),
            if (day == calendarPlannerToday)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.d2),
                child: Text(
                  'today',
                  style: theme.typography.face(
                    KevinSansFace.type,
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ),
          ],
        ),
        IndexCardContent(
          children: [
            if (events.isEmpty)
              Text(
                'Nothing planned. Leave it that way?',
                style: TextStyle(color: theme.colors.inkMuted),
              ),
            for (final event in events)
              CalendarPlannerAgendaRow(
                key: ValueKey(event.id),
                when: calendarPlannerClock(event.start),
                whenWidth: Spacing.d48,
                whenAlign: TextAlign.end,
                event: event,
                spoken:
                    '${calendarPlannerClock(event.start)} to ${calendarPlannerClock(event.end)}, ${event.kind.label}',
                onOpen: () => onOpen(event),
              ),
          ],
        ),
        IndexCardFooter(
          children: [
            Text(switch (events.length) {
              0 => 'a free day',
              1 => 'one thing',
              final count =>
                '${_numberWords.elementAtOrNull(count) ?? count} things',
            }),
          ],
        ),
      ],
    );
  }
}
