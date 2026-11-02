import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/calendar_planner/calendar_planner.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A month planner: a clipped calendar card, the chosen day and what is
/// coming up on index cards, and a taped form to add, change or delete
/// events.
///
/// Mirrors upstream `src/blocks/calendar-planner/page.tsx`.
class CalendarPlannerBlock extends StatefulWidget {
  const CalendarPlannerBlock({super.key});

  @override
  State<CalendarPlannerBlock> createState() => _CalendarPlannerBlockState();
}

typedef _Editing = ({CalendarPlannerEvent? event, String date});

class _CalendarPlannerBlockState extends State<CalendarPlannerBlock> {
  List<CalendarPlannerEvent> _all = calendarPlannerEvents;
  String _selected = calendarPlannerToday;
  DateTime _month = _monthOf(calendarPlannerToday);
  _Editing? _editing;
  String _message = '';

  static const double _maxWidth = 1024;
  static const double _sm = 640;
  static const double _lg = 1024;
  static const double _clipEnd = 50;

  static DateTime _monthOf(String iso) {
    final day = calendarPlannerParseDay(iso);
    return DateTime(day.year, day.month);
  }

  void _show(String iso) {
    _selected = iso;
    _month = _monthOf(iso);
  }

  void _open(_Editing editing) => setState(() => _editing = editing);

  void _save(CalendarPlannerEvent draft) => setState(() {
    final editing = draft.id.isNotEmpty;
    switch (editing) {
      case true:
        _all = [
          for (final event in _all)
            switch (event.id == draft.id) {
              true => draft,
              false => event,
            },
        ];
      case false:
        final next =
            _all.fold(
              0,
              (most, event) => switch (int.tryParse(event.id.substring(1))) {
                final n? when n > most => n,
                _ => most,
              },
            ) +
            1;
        _all = [..._all, draft.withId('e$next')];
    }
    _show(draft.date);
    _message =
        '${switch (editing) {
          true => 'Saved',
          false => 'Added',
        }} “${draft.title}” on ${calendarPlannerLongDay(draft.date)}.';
    _editing = null;
  });

  void _remove(CalendarPlannerEvent event) => setState(() {
    _all = [
      for (final other in _all)
        if (other.id != event.id) other,
    ];
    _message = 'Deleted “${event.title}”.';
    _editing = null;
  });

  String _dayLabel(DateTime day, {bool today = false, bool selected = false}) {
    final label = CalendarFormatters.labelDay(
      day,
      today: today,
      selected: selected,
    );
    final count = calendarPlannerOnDay(_all, calendarPlannerDayKey(day)).length;
    return switch (count) {
      0 => label,
      1 => '$label, 1 event',
      _ => '$label, $count events',
    };
  }

  Widget _header(BuildContext context, double width) {
    final theme = LooseleafTheme.of(context);
    return Wrap(
      spacing: Spacing.d16,
      runSpacing: Spacing.d16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d16,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d4,
              children: [
                Text(
                  'Planner',
                  style: theme.typography.face(
                    KevinSansFace.type,
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    calendarPlannerMonthTitle(_month),
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: switch (width >= _sm) {
                        true => 48,
                        false => 36,
                      },
                      cssLineHeight: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (width >= _sm)
              const Sticker('acorn-pair', size: 68, seed: 'planner-acorns'),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d12,
          children: [
            Button(
              variant: ButtonVariant.outline,
              onPressed: () => setState(() => _show(calendarPlannerToday)),
              child: const Text('Today'),
            ),
            Button(
              onPressed: () => _open((event: null, date: _selected)),
              leading: const InkIcon('calendar-plus'),
              child: const Text('New event'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _calendar(BuildContext context, {required bool wide}) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: switch (wide) {
        true => CrossAxisAlignment.start,
        false => CrossAxisAlignment.center,
      },
      spacing: Spacing.d16,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Calendar(
                required: true,
                selected: calendarPlannerParseDay(_selected),
                onSelect: (day) {
                  if (day == null) return;
                  setState(() => _show(calendarPlannerDayKey(day)));
                },
                month: _month,
                onMonthChange: (month) => setState(() => _month = month),
                today: calendarPlannerParseDay(calendarPlannerToday),
                seed: 'planner-month',
                sheet: const CalendarSheet(tilt: false),
                formatters: CalendarFormatters(dayLabel: _dayLabel),
              ),
              if (!PaperInk.calm(theme))
                const PositionedDirectional(
                  top: -Spacing.d20,
                  end: _clipEnd,
                  child: IgnorePointer(
                    child: PaperFastener(seed: 'planner-clip'),
                  ),
                ),
            ],
          ),
        ),
        Semantics(
          container: true,
          label: 'What the dots mean',
          child: Wrap(
            alignment: switch (wide) {
              true => WrapAlignment.start,
              false => WrapAlignment.center,
            },
            spacing: Spacing.d16,
            runSpacing: Spacing.d4,
            children: [
              for (final kind in CalendarPlannerKind.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d6,
                  children: [
                    CalendarPlannerDot(kind: kind),
                    Text(
                      kind.label,
                      style: theme.typography.face(
                        KevinSansFace.hand,
                        cssSize: 14,
                        color: theme.colors.inkMuted,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = calendarPlannerOnDay(_all, _selected).length;
    final editing = _editing;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = width >= _lg;
        final cards = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d24,
          children: [
            CalendarPlannerDayCard(
              day: _selected,
              list: _all,
              onOpen: (event) => _open((event: event, date: event.date)),
            ),
            CalendarPlannerComingUp(
              day: _selected,
              list: _all,
              onOpen: (event) => _open((event: event, date: event.date)),
            ),
          ],
        );
        return Dialog(
          open: editing != null,
          onOpenChange: (open) {
            if (!open) setState(() => _editing = null);
          },
          content: switch (editing) {
            null => const SizedBox.shrink(),
            final editing => CalendarPlannerEventDialog(
              key: ValueKey(editing.event?.id ?? 'new'),
              event: editing.event,
              date: editing.date,
              onSave: _save,
              onDelete: _remove,
            ),
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Padding(
                padding: EdgeInsets.all(switch (width) {
                  >= _lg => Spacing.d32,
                  >= _sm => Spacing.d24,
                  _ => Spacing.d16,
                }),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d24,
                  children: [
                    _header(context, width),
                    switch (wide) {
                      true => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d24,
                        children: [
                          _calendar(context, wide: true),
                          Expanded(child: cards),
                        ],
                      ),
                      false => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Spacing.d24,
                        children: [_calendar(context, wide: false), cards],
                      ),
                    },
                    Semantics(
                      liveRegion: true,
                      label: switch (_message.isEmpty) {
                        true =>
                          '$count ${switch (count) {
                            1 => 'event',
                            _ => 'events',
                          }} on ${calendarPlannerLongDay(_selected)}.',
                        false => _message,
                      },
                      child: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
