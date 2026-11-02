import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/calendar_planner/calendar_planner.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The next five events after the chosen day, on a stack of index cards
/// with a sky flag.
///
/// Mirrors `ComingUp` in upstream
/// `src/blocks/calendar-planner/components/calendar-planner-agenda.tsx`.
class CalendarPlannerComingUp extends StatelessWidget {
  const CalendarPlannerComingUp({
    super.key,
    required this.day,
    required this.list,
    required this.onOpen,
  });

  final String day;
  final List<CalendarPlannerEvent> list;
  final ValueChanged<CalendarPlannerEvent> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final next = calendarPlannerAfter(list, day);
    return IndexCard(
      seed: 'planner-next',
      tilt: false,
      stack: 2,
      flag: Accent.sky,
      maxWidth: double.infinity,
      children: [
        const IndexCardHeader(children: [IndexCardTitle(Text('Coming up'))]),
        IndexCardContent(
          children: [
            if (next.isEmpty)
              Text(
                'Nothing after this day yet.',
                style: TextStyle(color: theme.colors.inkMuted),
              ),
            for (final event in next)
              CalendarPlannerAgendaRow(
                key: ValueKey(event.id),
                when: calendarPlannerShortDay(event.date),
                whenWidth: Spacing.d76,
                whenAlign: TextAlign.start,
                event: event,
                spoken:
                    '${calendarPlannerLongDay(event.date)}, ${calendarPlannerClock(event.start)}, ${event.kind.label}',
                onOpen: () => onOpen(event),
              ),
          ],
        ),
      ],
    );
  }
}
