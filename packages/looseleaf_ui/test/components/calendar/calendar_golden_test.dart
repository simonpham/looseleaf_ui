import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

final DateTime _today = DateTime(2026, 9, 15);
final DateTime _september = DateTime(2026, 9);

Widget _planner() => Calendar(
  selected: DateTime(2026, 9, 17),
  onSelect: (_) {},
  defaultMonth: _september,
  today: _today,
  isDateDisabled: (day) => day.isBefore(DateTime(2026, 9, 3)),
  sheet: const CalendarSheet(tape: PaperTape.corner, seed: 'planner'),
  seed: 'planner',
);

Widget _range() => Calendar.range(
  numberOfMonths: 2,
  showWeekNumber: true,
  selected: DateRange(
    from: DateTime(2026, 9, 24),
    to: DateTime(2026, 10, 6),
  ),
  onSelect: (_) {},
  defaultMonth: _september,
  today: _today,
  sheet: const CalendarSheet(
    stock: StockName.paper,
    fastener: FastenerKind.binderClip,
    tiltDegrees: 0.4,
  ),
  seed: 'range',
);

Widget _limits() => Calendar(
  captionLayout: CalendarCaptionLayout.dropdown,
  onSelect: (_) {},
  defaultMonth: _september,
  startMonth: DateTime(2024),
  endMonth: DateTime(2028, 12),
  today: _today,
  isDateDisabled: (day) =>
      day.weekday == DateTime.saturday ||
      day.weekday == DateTime.sunday ||
      day.isBefore(_today),
  sheet: const CalendarSheet(),
  seed: 'limits',
  footer: const Text('Pick a weekday from the 15th on.'),
);

Widget _rtl() => Directionality(
  textDirection: TextDirection.rtl,
  child: Calendar.multiple(
    weekStartsOn: 1,
    selected: [DateTime(2026, 9, 6), DateTime(2026, 9, 13)],
    onSelect: (_) {},
    defaultMonth: _september,
    today: _today,
    sheet: const CalendarSheet(),
    seed: 'ar',
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  for (final (name, build, size) in [
    ('calendar-planner', _planner, const Size(900, 900)),
    ('calendar-range', _range, const Size(1800, 1000)),
    ('calendar-limits', _limits, const Size(900, 1000)),
    ('calendar-rtl', _rtl, const Size(900, 900)),
  ]) {
    testWidgets('$name in the light theme', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        componentHost(paperPanel(Center(child: build()))),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find
            .ancestor(
              of: find.byType(Calendar),
              matching: find.byType(RepaintBoundary),
            )
            .first,
        matchesGoldenFile('../goldens/$name.png'),
      );
    });
  }

  testWidgets('calendar-focus: the drawn loop under the keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await tester.pumpWidget(
      componentHost(paperPanel(Center(child: _planner()))),
    );
    Focus.of(tester.element(find.text('17').first)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await expectLater(
      find
          .ancestor(
            of: find.byType(Calendar),
            matching: find.byType(RepaintBoundary),
          )
          .first,
      matchesGoldenFile('../goldens/calendar-focus.png'),
    );
  });
}
