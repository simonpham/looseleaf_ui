import 'package:gallery/features/components/examples/date_picker/date_picker.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/date-picker/`.
const datePickerExamples = <GalleryExample>[
  GalleryExample(
    title: 'Type it or pick it',
    description:
        'Type a date any way you would write it (9/17/26, 2026-09-17, Sep 17, tomorrow) and press Enter, or open the calendar and circle a day. Days before the 3rd are hatched out, so typing one turns the box red.',
    height: 470,
    source: 'date_picker/date_picker_typed_date_example.dart',
    builder: DatePickerTypedDateExample.new,
  ),
  GalleryExample(
    title: 'With presets',
    description:
        'A column of shortcuts beside the calendar. A preset is a function, so \'in a week\' is worked out when you choose it, not when the page was drawn.',
    height: 470,
    source: 'date_picker/date_picker_presets_example.dart',
    builder: DatePickerPresetsExample.new,
  ),
  GalleryExample(
    title: 'A date range',
    description:
        'Two ends in one field. Type \'Sep 9, 2026 to Sep 24, 2026\' or open the two-month calendar: each week of the range gets one highlighter swipe, and the slip puts itself away when the second end is chosen.',
    height: 500,
    source: 'date_picker/date_picker_date_range_example.dart',
    builder: DatePickerDateRangeExample.new,
  ),
  GalleryExample(
    title: 'As a button',
    description:
        'typeable: false makes the whole field a button that shows the date, like a Select. Below it: invalid, disabled and a dropdown caption for far-away dates such as birthdays.',
    layout: ExampleLayout.stack,
    height: 480,
    source: 'date_picker/date_picker_button_field_example.dart',
    builder: DatePickerButtonFieldExample.new,
  ),
  GalleryExample(
    title: 'Reserve a table',
    description:
        'In a real form: the date is plain state (sent as 2026-09-17), Mondays are closed, and the summary reads what was sent.',
    stage: ExampleStage.desk,
    height: 560,
    source: 'date_picker/date_picker_reserve_a_table_example.dart',
    builder: DatePickerReserveATableExample.new,
  ),
];
