import 'package:gallery/features/components/examples/calendar/calendar.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/calendar/`.
const calendarExamples = <GalleryExample>[
  GalleryExample(
    title: 'Planner page',
    description: 'One chosen day, circled in marker; today underlined; the days before the 3rd hatched out. On its own sheet of card, taped at the corner. (Fixed dates, so the page looks the same tomorrow.)',
    stage: ExampleStage.desk,
    height: 380,
    source: 'calendar/calendar_planner_page_example.dart',
    builder: CalendarPlannerPageExample.new,
  ),
  GalleryExample(
    title: 'A range across two months',
    description: 'Pick a first and a last day and each week gets one highlighter swipe with chisel ends; week numbers go in the margin behind a red pencil rule.',
    stage: ExampleStage.desk,
    height: 420,
    source: 'calendar/calendar_range_two_months_example.dart',
    builder: CalendarRangeTwoMonthsExample.new,
  ),
  GalleryExample(
    title: 'Dropdowns and limits',
    description: 'Month and year are dropdowns in pencil boxes, so jumping to a birthday takes two taps. Weekends and the past are hatched out and cannot be chosen; the arrows stop at the ends of the range.',
    height: 430,
    source: 'calendar/calendar_dropdowns_and_limits_example.dart',
    builder: CalendarDropdownsAndLimitsExample.new,
  ),
  GalleryExample(
    title: 'Book a call',
    description: 'A calendar on a card with time slots beside it: the chosen day drives the slots, the chosen slot drives the button. Weekends are closed, so they are hatched.',
    stage: ExampleStage.desk,
    height: 520,
    source: 'calendar/calendar_book_a_call_example.dart',
    builder: CalendarBookACallExample.new,
  ),
  GalleryExample(
    title: 'Other languages',
    description: 'Pass your own CalendarFormatters: Spanish starts the week on Monday; Arabic runs right to left, with Eastern Arabic numerals and one-letter weekdays, and the rules, arrows and swipe ends turn around with it.',
    source: 'calendar/calendar_locales_example.dart',
    builder: CalendarLocalesExample.new,
  ),
];
