import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// What sort of thing an event is, and the colour of its dot.
enum CalendarPlannerKind {
  studio('Studio'),
  home('Home'),
  friends('Friends'),
  trips('Trips'),
  errands('Errands');

  const CalendarPlannerKind(this.label);

  final String label;

  /// The dot's paint (upstream `bg-tomato`, `bg-grass`, …).
  Color dot(LooseleafColors colors) => switch (this) {
    studio => colors.tomato,
    home => colors.grass,
    friends => colors.sky,
    trips => colors.grape,
    errands => colors.lemon,
  };
}

/// One thing on the calendar. [date] is `yyyy-mm-dd`, [start] and [end]
/// are `hh:mm`.
///
/// Mirrors `PlannerEvent` in upstream
/// `src/blocks/calendar-planner/components/calendar-planner-data.ts`.
class CalendarPlannerEvent {
  const CalendarPlannerEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.start,
    required this.end,
    required this.kind,
    this.notes = '',
  });

  final String id;
  final String title;
  final String date;
  final String start;
  final String end;
  final CalendarPlannerKind kind;
  final String notes;

  CalendarPlannerEvent withId(String id) => CalendarPlannerEvent(
    id: id,
    title: title,
    date: date,
    start: start,
    end: end,
    kind: kind,
    notes: notes,
  );
}

const calendarPlannerToday = '2026-09-25';

const calendarPlannerEvents = <CalendarPlannerEvent>[
  CalendarPlannerEvent(
    id: 'e1',
    title: 'Watercolor class',
    date: '2026-09-03',
    start: '18:30',
    end: '20:30',
    kind: CalendarPlannerKind.home,
    notes: 'Bring the small brushes.',
  ),
  CalendarPlannerEvent(
    id: 'e2',
    title: 'Kiln day',
    date: '2026-09-10',
    start: '09:00',
    end: '13:00',
    kind: CalendarPlannerKind.studio,
  ),
  CalendarPlannerEvent(
    id: 'e3',
    title: 'Dinner with the neighbors',
    date: '2026-09-12',
    start: '19:30',
    end: '22:00',
    kind: CalendarPlannerKind.friends,
    notes: 'We are bringing the tart.',
  ),
  CalendarPlannerEvent(
    id: 'e4',
    title: 'Dentist',
    date: '2026-09-16',
    start: '08:30',
    end: '09:15',
    kind: CalendarPlannerKind.home,
  ),
  CalendarPlannerEvent(
    id: 'e5',
    title: 'Order the boxes',
    date: '2026-09-21',
    start: '11:00',
    end: '11:30',
    kind: CalendarPlannerKind.errands,
  ),
  CalendarPlannerEvent(
    id: 'e6',
    title: 'Studio stand-up',
    date: '2026-09-25',
    start: '09:30',
    end: '10:00',
    kind: CalendarPlannerKind.studio,
    notes: 'Price tags, sticker sheet, newsletter.',
  ),
  CalendarPlannerEvent(
    id: 'e7',
    title: 'Lunch with Ada',
    date: '2026-09-25',
    start: '12:30',
    end: '14:00',
    kind: CalendarPlannerKind.friends,
    notes: 'The place with the good bread.',
  ),
  CalendarPlannerEvent(
    id: 'e8',
    title: 'Post office run',
    date: '2026-09-25',
    start: '16:00',
    end: '16:45',
    kind: CalendarPlannerKind.errands,
    notes: 'Two parcels and a postcard.',
  ),
  CalendarPlannerEvent(
    id: 'e9',
    title: 'Farmers market',
    date: '2026-09-26',
    start: '10:00',
    end: '12:00',
    kind: CalendarPlannerKind.errands,
  ),
  CalendarPlannerEvent(
    id: 'e10',
    title: "Ada's birthday supper",
    date: '2026-09-26',
    start: '19:30',
    end: '23:00',
    kind: CalendarPlannerKind.friends,
    notes: "Don't forget the card.",
  ),
  CalendarPlannerEvent(
    id: 'e11',
    title: 'Print the price tags',
    date: '2026-09-28',
    start: '09:00',
    end: '12:00',
    kind: CalendarPlannerKind.studio,
    notes: 'Kraft card, two hundred.',
  ),
  CalendarPlannerEvent(
    id: 'e12',
    title: 'Newsletter deadline',
    date: '2026-09-29',
    start: '10:00',
    end: '11:00',
    kind: CalendarPlannerKind.studio,
  ),
  CalendarPlannerEvent(
    id: 'e13',
    title: 'Train to Lyon',
    date: '2026-09-30',
    start: '08:15',
    end: '11:40',
    kind: CalendarPlannerKind.trips,
    notes: 'Seat 42, by the window.',
  ),
  CalendarPlannerEvent(
    id: 'e14',
    title: 'Paper fair, day one',
    date: '2026-10-01',
    start: '09:00',
    end: '18:00',
    kind: CalendarPlannerKind.trips,
  ),
  CalendarPlannerEvent(
    id: 'e15',
    title: 'Paper fair, day two',
    date: '2026-10-02',
    start: '09:00',
    end: '17:00',
    kind: CalendarPlannerKind.trips,
    notes: 'Say hello to the marbling people.',
  ),
  CalendarPlannerEvent(
    id: 'e16',
    title: 'Train home',
    date: '2026-10-02',
    start: '18:30',
    end: '22:00',
    kind: CalendarPlannerKind.trips,
  ),
];

const _weekdays = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// `2026-09-25` as a local date.
DateTime calendarPlannerParseDay(String iso) {
  final [year, month, day] = [
    for (final part in iso.split('-')) int.parse(part),
  ];
  return DateTime(year, month, day);
}

/// A date as `yyyy-mm-dd`.
String calendarPlannerDayKey(DateTime day) =>
    '${day.year}-${'${day.month}'.padLeft(2, '0')}-${'${day.day}'.padLeft(2, '0')}';

/// `09:30` as `9:30`.
String calendarPlannerClock(String hhmm) =>
    '${int.parse(hhmm.substring(0, 2))}:${hhmm.substring(3, 5)}';

/// `Friday 25 September` (date-fns `EEEE d MMMM`).
String calendarPlannerLongDay(String iso) {
  final day = calendarPlannerParseDay(iso);
  return '${_weekdays[day.weekday % 7]} ${day.day} ${_months[day.month - 1]}';
}

/// `Fri 25` (date-fns `EEE d`).
String calendarPlannerShortDay(String iso) {
  final day = calendarPlannerParseDay(iso);
  return '${_weekdays[day.weekday % 7].substring(0, 3)} ${day.day}';
}

/// `September 2026` (date-fns `MMMM yyyy`).
String calendarPlannerMonthTitle(DateTime month) =>
    '${_months[month.month - 1]} ${month.year}';

/// The events of day [iso], earliest first.
List<CalendarPlannerEvent> calendarPlannerOnDay(
  List<CalendarPlannerEvent> list,
  String iso,
) =>
    [
      for (final event in list)
        if (event.date == iso) event,
    ]..sort(
      (a, b) => switch (a.start.compareTo(b.start)) {
        0 => a.id.compareTo(b.id),
        final order => order,
      },
    );

/// The first [count] events after day [iso].
List<CalendarPlannerEvent> calendarPlannerAfter(
  List<CalendarPlannerEvent> list,
  String iso, {
  int count = 5,
}) =>
    ([
          for (final event in list)
            if (event.date.compareTo(iso) > 0) event,
        ]..sort(
          (a, b) => switch (a.date.compareTo(b.date)) {
            0 => a.start.compareTo(b.start),
            final order => order,
          },
        ))
        .take(count)
        .toList();
