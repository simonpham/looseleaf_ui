import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';
import '../../support/semantics_matchers.dart';

final DateTime _today = DateTime(2026, 11, 2);

class _Harness extends StatefulWidget {
  const _Harness({this.typeable = true, this.withPresets = false});

  final bool typeable;
  final bool withPresets;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  DateTime? value = DateTime(2026, 9, 17);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    child: DatePicker(
      value: value,
      typeable: widget.typeable,
      semanticLabel: 'Due date',
      now: () => _today,
      min: DateTime(2026),
      onChanged: (next) => setState(() => value = next),
      presets: switch (widget.withPresets) {
        true => [
          DatePreset(label: 'Tomorrow', value: () => DateTime(2026, 11, 3)),
        ],
        false => const [],
      },
      calendarBuilder: (context, selected, onSelect, isDisabled) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Selected ${selected?.day}'),
          GestureDetector(
            onTap: () => onSelect(DateTime(2026, 9, 20)),
            child: const Text('Day 20'),
          ),
        ],
      ),
    ),
  );
}

DateTime? _value(WidgetTester tester) =>
    tester.state<_HarnessState>(find.byType(_Harness)).value;

void main() {
  testWidgets('shows the chosen day in the PP format', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    expect(find.text('Sep 17, 2026'), findsOneWidget);
  });

  testWidgets('typed dates are read on Enter', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.enterText(find.byType(EditableText), 'tomorrow');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_value(tester), DateTime(2026, 11, 3));
    expect(find.text('Nov 3, 2026'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), '2026-12-24');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_value(tester), DateTime(2026, 12, 24));
  });

  testWidgets('an unreadable or disallowed date draws the red box', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.enterText(find.byType(EditableText), 'someday');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    InkSurface surface() => tester.widget<InkSurface>(
      find.byType(InkSurface).first,
    );
    expect(surface().states, contains(InkState.invalid));
    expect(_value(tester), DateTime(2026, 9, 17));
    await tester.enterText(find.byType(EditableText), '1/2/2025');
    await tester.pump();
    expect(surface().states, isNot(contains(InkState.invalid)));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(surface().states, contains(InkState.invalid));
  });

  testWidgets('Escape drops unsent text', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.enterText(find.byType(EditableText), 'Oct 1');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('Sep 17, 2026'), findsOneWidget);
  });

  testWidgets('the calendar button opens the popup; picking closes it', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.tap(find.bySemanticsLabel('Choose date'));
    await tester.pumpAndSettle();
    expect(find.text('Selected 17'), findsOneWidget);
    await tester.tap(find.text('Day 20'));
    await tester.pumpAndSettle();
    expect(_value(tester), DateTime(2026, 9, 20));
    expect(find.text('Day 20'), findsNothing);
  });

  testWidgets('ArrowDown opens, Escape closes', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.tap(find.byType(EditableText));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('Day 20'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Day 20'), findsNothing);
  });

  testWidgets('presets set the day and close', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness(withPresets: true)));
    await tester.tap(find.bySemanticsLabel('Choose date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();
    expect(_value(tester), DateTime(2026, 11, 3));
    expect(find.text('Tomorrow'), findsNothing);
  });

  testWidgets('the button field reads as an expandable button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(const _Harness(typeable: false)));
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('Due date'))),
      includesSemantics(
        label: 'Due date\nSep 17, 2026',
        isButton: true,
        hasExpandedState: true,
        isExpanded: false,
      ),
    );
    await tester.tap(find.text('Sep 17, 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Day 20'), findsOneWidget);
    handle.dispose();
  });

  group('parseDateInput', () {
    final reference = DateTime(2026, 11, 2);
    for (final (text, day) in [
      ('Sep 17, 2026', DateTime(2026, 9, 17)),
      ('September 17th, 2026', DateTime(2026, 9, 17)),
      ('17 Sep 2026', DateTime(2026, 9, 17)),
      ('2026-09-17', DateTime(2026, 9, 17)),
      ('2026/9/17', DateTime(2026, 9, 17)),
      ('9/17/2026', DateTime(2026, 9, 17)),
      ('9/17/26', DateTime(2026, 9, 17)),
      ('17.9.2026', DateTime(2026, 9, 17)),
      ('1/1/80', DateTime(1980)),
      ('1/1/60', DateTime(2060)),
      ('yesterday', DateTime(2026, 11, 1)),
    ]) {
      test(text, () => expect(parseDateInput(text, reference: reference), day));
    }
    test('rejects impossible days', () {
      expect(parseDateInput('2/30/2026', reference: reference), isNull);
      expect(parseDateInput('soon', reference: reference), isNull);
    });
  });

  test('formats like date-fns', () {
    final day = DateTime(2026, 9, 2);
    expect(formatDateMedium(day), 'Sep 2, 2026');
    expect(formatDateShort(day), '09/02/2026');
    expect(formatDateLong(day), 'September 2nd, 2026');
    expect(toIsoDate(day), '2026-09-02');
  });

  testWidgets('a typed range is read in order', (tester) async {
    DateRange? range;
    await tester.pumpWidget(
      overlayHost(
        SizedBox(
          width: 300,
          child: StatefulBuilder(
            builder: (context, setState) => DateRangePicker(
              value: range,
              onChanged: (next) => setState(() => range = next),
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(EditableText), '9/9/2026 to 9/1/2026');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(range, DateRange(from: DateTime(2026, 9), to: DateTime(2026, 9, 9)));
    expect(find.text('Sep 1, 2026 – Sep 9, 2026'), findsOneWidget);
  });

  testWidgets('the default calendar opens on the day and picks one', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    DateTime? value = DateTime(2026, 9, 17);
    await tester.pumpWidget(
      overlayHost(
        SizedBox(
          width: 260,
          child: StatefulBuilder(
            builder: (context, setState) => DatePicker(
              value: value,
              min: DateTime(2026, 9, 3),
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Choose date'));
    await tester.pumpAndSettle();
    expect(find.byType(Calendar), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    final disabled = tester.widget<CalendarDayButton>(
      find.ancestor(
        of: find.text('2').first,
        matching: find.byType(CalendarDayButton),
      ),
    );
    expect(disabled.disabled, isTrue);
    await tester.tap(find.text('17').last);
    await tester.pumpAndSettle();
    expect(value, DateTime(2026, 9, 17));
    expect(find.byType(Calendar), findsNothing);
    await tester.tap(find.bySemanticsLabel('Choose date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('24').last);
    await tester.pumpAndSettle();
    expect(value, DateTime(2026, 9, 24));
    expect(find.byType(Calendar), findsNothing);
  });

  testWidgets('the default range calendar shows two months', (tester) async {
    tester.view.physicalSize = const Size(2000, 1400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    DateRange? range = DateRange(from: DateTime(2026, 9, 24));
    await tester.pumpWidget(
      overlayHost(
        SizedBox(
          width: 300,
          child: StatefulBuilder(
            builder: (context, setState) => DateRangePicker(
              value: range,
              open: true,
              onChanged: (next) => setState(() => range = next),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    await tester.tap(find.text('6').last);
    await tester.pumpAndSettle();
    expect(
      range,
      DateRange(from: DateTime(2026, 9, 24), to: DateTime(2026, 10, 6)),
    );
  });
}
