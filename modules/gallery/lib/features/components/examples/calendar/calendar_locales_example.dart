import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CalendarLocalesExample extends StatefulWidget {
  const CalendarLocalesExample({super.key});

  @override
  State<CalendarLocalesExample> createState() => _CalendarLocalesExampleState();
}

class _CalendarLocalesExampleState extends State<CalendarLocalesExample> {
  static const _esMonths = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  static const _esWeekdays = ['lu', 'ma', 'mi', 'ju', 'vi', 'sá', 'do'];
  static const _arMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  static const _arWeekdays = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
  static const _arDigits = '٠١٢٣٤٥٦٧٨٩';

  static String _arab(int number) => [
    for (final digit in number.toString().split(''))
      _arDigits[int.parse(digit)],
  ].join();

  static final _spanish = CalendarFormatters(
    caption: (month) => '${_esMonths[month.month - 1]} ${month.year}',
    weekdayName: (day) => _esWeekdays[day.weekday - 1],
  );

  static final _arabic = CalendarFormatters(
    caption: (month) => '${_arMonths[month.month - 1]} ${_arab(month.year)}',
    weekdayName: (day) => _arWeekdays[day.weekday - 1],
    day: (day) => _arab(day.day),
  );

  DateTime? _a = DateTime(2026, 9, 17);
  List<DateTime> _b = [DateTime(2026, 9, 6), DateTime(2026, 9, 13)];

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d32,
    runSpacing: Spacing.d32,
    alignment: WrapAlignment.center,
    children: [
      Calendar(
        formatters: _spanish,
        weekStartsOn: 1,
        selected: _a,
        onSelect: (date) => setState(() => _a = date),
        defaultMonth: DateTime(2026, 9),
        today: DateTime(2026, 9, 15),
        sheet: const CalendarSheet(),
        seed: 'es',
      ),
      Directionality(
        textDirection: TextDirection.rtl,
        child: Calendar.multiple(
          formatters: _arabic,
          selected: _b,
          onSelect: (days) => setState(() => _b = days),
          defaultMonth: DateTime(2026, 9),
          today: DateTime(2026, 9, 15),
          sheet: const CalendarSheet(),
          seed: 'ar',
        ),
      ),
    ],
  );
}
