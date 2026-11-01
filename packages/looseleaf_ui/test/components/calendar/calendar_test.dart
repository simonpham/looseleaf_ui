import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

final DateTime _today = DateTime(2026, 9, 15);
final DateTime _september = DateTime(2026, 9);

Finder _day(int day) => find.descendant(
  of: find.byType(CalendarDayButton),
  matching: find.text('$day'),
);

FocusNode _focusOf(WidgetTester tester, int day) =>
    Focus.of(tester.element(_day(day).first));

DateTime? _focusedDay(WidgetTester tester) {
  final focused = tester.widgetList<CalendarDayButton>(
    find.byType(CalendarDayButton),
  );
  for (final button in focused) {
    if (button.focusNode?.hasPrimaryFocus ?? false) return button.day;
  }
  return null;
}

void main() {
  testWidgets('single: picks a day, clears it on a second tap', (
    tester,
  ) async {
    DateTime? picked = DateTime(2026, 9, 17);
    await tester.pumpWidget(
      overlayHost(
        StatefulBuilder(
          builder: (context, setState) => Calendar(
            selected: picked,
            onSelect: (day) => setState(() => picked = day),
            defaultMonth: _september,
            today: _today,
          ),
        ),
      ),
    );
    await tester.tap(_day(20).first);
    await tester.pump();
    expect(picked, DateTime(2026, 9, 20));
    await tester.tap(_day(20).first);
    await tester.pump();
    expect(picked, isNull);
  });

  testWidgets('single and required: a second tap keeps the day', (
    tester,
  ) async {
    DateTime? picked = DateTime(2026, 9, 17);
    await tester.pumpWidget(
      overlayHost(
        Calendar(
          required: true,
          selected: picked,
          onSelect: (day) => picked = day,
          defaultMonth: _september,
        ),
      ),
    );
    await tester.tap(_day(17).first);
    expect(picked, DateTime(2026, 9, 17));
  });

  testWidgets('multiple: each tap toggles a day', (tester) async {
    var picked = <DateTime>[DateTime(2026, 9, 6)];
    await tester.pumpWidget(
      overlayHost(
        StatefulBuilder(
          builder: (context, setState) => Calendar.multiple(
            selected: picked,
            onSelect: (days) => setState(() => picked = days),
            defaultMonth: _september,
          ),
        ),
      ),
    );
    await tester.tap(_day(13).first);
    await tester.pump();
    expect(picked, [DateTime(2026, 9, 6), DateTime(2026, 9, 13)]);
    await tester.tap(_day(6).first);
    await tester.pump();
    expect(picked, [DateTime(2026, 9, 13)]);
  });

  testWidgets('range: a first tap starts, a second ends, earlier restarts', (
    tester,
  ) async {
    DateRange? picked;
    await tester.pumpWidget(
      overlayHost(
        StatefulBuilder(
          builder: (context, setState) => Calendar.range(
            selected: picked,
            onSelect: (range) => setState(() => picked = range),
            defaultMonth: _september,
          ),
        ),
      ),
    );
    await tester.tap(_day(10).first);
    await tester.pump();
    expect(
      picked,
      DateRange(from: DateTime(2026, 9, 10), to: DateTime(2026, 9, 10)),
    );
    await tester.tap(_day(16).first);
    await tester.pump();
    expect(
      picked,
      DateRange(from: DateTime(2026, 9, 10), to: DateTime(2026, 9, 16)),
    );
    await tester.tap(_day(8).first);
    await tester.pump();
    expect(
      picked,
      DateRange(from: DateTime(2026, 9, 8), to: DateTime(2026, 9, 16)),
    );
    final bands = {
      for (final button in tester.widgetList<CalendarDayButton>(
        find.byType(CalendarDayButton),
      ))
        button.day.day: ?button.band,
    };
    expect(bands[8], CalendarBandKind.start);
    expect(bands[12], CalendarBandKind.end);
    expect(bands[13], CalendarBandKind.start);
    expect(bands[14], CalendarBandKind.mid);
    expect(bands[16], CalendarBandKind.end);
  });

  testWidgets('disabled days ignore taps and keys skip them', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      overlayHost(
        Calendar(
          selected: DateTime(2026, 9, 17),
          onSelect: (day) => picked = day,
          defaultMonth: _september,
          isDateDisabled: (day) => day.day == 18 || day.day == 19,
        ),
      ),
    );
    await tester.tap(_day(18).first, warnIfMissed: false);
    expect(picked, isNull);
    _focusOf(tester, 17).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_focusedDay(tester), DateTime(2026, 9, 20));
  });

  testWidgets('keys move by day, week, month and year, Enter picks', (
    tester,
  ) async {
    DateTime? picked;
    await tester.pumpWidget(
      overlayHost(
        Calendar(
          selected: DateTime(2026, 9, 17),
          onSelect: (day) => picked = day,
          defaultMonth: _september,
        ),
      ),
    );
    _focusOf(tester, 17).requestFocus();
    await tester.pump();
    for (final (key, day) in [
      (LogicalKeyboardKey.arrowRight, DateTime(2026, 9, 18)),
      (LogicalKeyboardKey.arrowDown, DateTime(2026, 9, 25)),
      (LogicalKeyboardKey.arrowLeft, DateTime(2026, 9, 24)),
      (LogicalKeyboardKey.arrowUp, DateTime(2026, 9, 17)),
      (LogicalKeyboardKey.home, DateTime(2026, 9, 13)),
      (LogicalKeyboardKey.end, DateTime(2026, 9, 19)),
      (LogicalKeyboardKey.pageDown, DateTime(2026, 10, 19)),
    ]) {
      await tester.sendKeyEvent(key);
      await tester.pump();
      expect(_focusedDay(tester), day, reason: '$key');
    }
    expect(find.text('October 2026'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(_focusedDay(tester), DateTime(2025, 10, 19));
    expect(find.text('October 2025'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(picked, DateTime(2025, 10, 19));
  });

  testWidgets('right to left swaps the horizontal arrows', (tester) async {
    await tester.pumpWidget(
      overlayHost(
        Directionality(
          textDirection: TextDirection.rtl,
          child: Calendar(
            selected: DateTime(2026, 9, 17),
            defaultMonth: _september,
          ),
        ),
      ),
    );
    _focusOf(tester, 17).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(_focusedDay(tester), DateTime(2026, 9, 18));
    expect(
      tester.getCenter(_day(18).first).dx,
      lessThan(tester.getCenter(_day(17).first).dx),
    );
  });

  testWidgets('one day is the tab stop', (tester) async {
    await tester.pumpWidget(
      overlayHost(
        Calendar(
          selected: DateTime(2026, 9, 17),
          defaultMonth: _september,
          today: _today,
        ),
      ),
    );
    final stops = tester
        .widgetList<CalendarDayButton>(find.byType(CalendarDayButton))
        .where((button) => !(button.focusNode?.skipTraversal ?? true))
        .map((button) => button.day);
    expect(stops, [DateTime(2026, 9, 17)]);
  });

  testWidgets('the arrows page and stop at the limits', (tester) async {
    final months = <DateTime>[];
    await tester.pumpWidget(
      overlayHost(
        Calendar(
          defaultMonth: _september,
          startMonth: DateTime(2026, 8),
          endMonth: DateTime(2026, 9),
          onMonthChange: months.add,
        ),
      ),
    );
    expect(find.text('September 2026'), findsOneWidget);
    final next = find.bySemanticsLabel('Go to the Next Month');
    final previous = find.bySemanticsLabel('Go to the Previous Month');
    await tester.tap(next, warnIfMissed: false);
    await tester.pump();
    expect(months, isEmpty);
    await tester.tap(previous);
    await tester.pump();
    expect(find.text('August 2026'), findsOneWidget);
    expect(months, [DateTime(2026, 8)]);
  });

  testWidgets('a dropdown jumps to the month picked', (tester) async {
    await tester.pumpWidget(
      overlayHost(
        Calendar(
          captionLayout: CalendarCaptionLayout.dropdown,
          defaultMonth: _september,
          startMonth: DateTime(2024),
          endMonth: DateTime(2028, 12),
        ),
      ),
    );
    expect(find.text('Sep'), findsOneWidget);
    await tester.tap(find.text('Sep'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Nov'), findsOneWidget);
    expect(_day(30), findsWidgets);
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2028').last);
    await tester.pumpAndSettle();
    expect(find.text('2028'), findsOneWidget);
  });

  testWidgets('days carry their full date, today and selection', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      overlayHost(
        Calendar(
          selected: DateTime(2026, 9, 17),
          defaultMonth: _september,
          today: _today,
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Today, Tuesday, September 15th, 2026'),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(
        find.bySemanticsLabel('Thursday, September 17th, 2026, selected'),
      ),
      matchesSemantics(
        label: 'Thursday, September 17th, 2026, selected',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('week numbers fill the margin', (tester) async {
    await tester.pumpWidget(
      overlayHost(Calendar(defaultMonth: _september, showWeekNumber: true)),
    );
    for (final week in ['36', '37', '38', '39', '40']) {
      expect(find.text(week), findsOneWidget);
    }
  });

  testWidgets('cells follow the density', (tester) async {
    for (final (density, cell) in [
      (LooseleafDensity.comfortable, 40.0),
      (LooseleafDensity.compact, 34.0),
      (LooseleafDensity.calm, 30.0),
    ]) {
      await tester.pumpWidget(
        overlayHost(
          Calendar(defaultMonth: _september),
          theme: LooseleafThemeData(density: density),
        ),
      );
      expect(
        tester.getSize(find.byType(CalendarDayButton).first),
        Size.square(cell),
      );
    }
  });

  test('dates: weeks, week numbers and ranges', () {
    expect(CalendarDates.weeks(_september, weekStartsOn: 0), hasLength(5));
    expect(
      CalendarDates.weeks(DateTime(2026, 8), weekStartsOn: 0),
      hasLength(6),
    );
    expect(
      CalendarDates.weeks(_september, weekStartsOn: 0, fixedWeeks: true),
      hasLength(6),
    );
    expect(CalendarDates.weekNumber(DateTime(2026, 9, 1), 0), 36);
    expect(CalendarDates.weekNumber(DateTime(2026, 1, 1), 0), 1);
    expect(CalendarDates.weekNumber(DateTime(2026, 12, 31), 0), 1);
    expect(
      CalendarDates.addToRange(
        DateTime(2026, 9, 5),
        DateRange(from: DateTime(2026, 9, 5), to: DateTime(2026, 9, 5)),
      ),
      isNull,
    );
  });
}
