import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_dates.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_formatters.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_metrics.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds the cell of [day] in week [row] of a [CalendarMonthGrid].
typedef CalendarDayBuilder =
    Widget Function(
      BuildContext context,
      DateTime day,
      int row,
    );

/// One month's table on a [Calendar]: the weekday heads, the week numbers
/// in a red-ruled margin, and the days, over a hand-ruled grid
/// (`calendarGridRecipe`).
///
/// Mirrors `CalendarMonthGrid` in upstream
/// `src/components/ui/calendar.tsx`.
class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    super.key,
    required this.weeks,
    required this.dayBuilder,
    required this.seed,
    this.weekStartsOn = 0,
    this.showWeekNumber = false,
    this.ruled = true,
    this.formatters = const CalendarFormatters(),
    this.active,
    this.cellSize,
  });

  /// The rows of seven days, from [CalendarDates.weeks].
  final List<List<DateTime>> weeks;

  final CalendarDayBuilder dayBuilder;

  /// Pins the rules.
  final String seed;

  /// The first weekday, 0 for Sunday.
  final int weekStartsOn;

  /// The week numbers in the margin.
  final bool showWeekNumber;

  /// Hand-rules the grid.
  final bool ruled;

  final CalendarFormatters formatters;

  /// The day holding the roving focus: its cell paints last so its focus
  /// loop sits over its neighbours.
  final DateTime? active;

  /// A day's side; [CalendarMetrics.cell] for the density when null.
  final double? cellSize;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final cell = cellSize ?? CalendarMetrics.cell.resolve(theme.density);
    final margin = switch (showWeekNumber) {
      true => CalendarMetrics.weekNumber,
      false => 0.0,
    };
    final width = margin + 7 * cell;
    final height = CalendarMetrics.head + weeks.length * cell;
    final type = theme.typography.face(
      KevinSansFace.type,
      cssSize: CalendarMetrics.weekdaySize,
      cssLineHeight: 1,
      color: colors.pencilText,
    );
    final cells = <(bool, Widget)>[];
    for (final (row, week) in weeks.indexed) {
      for (final (column, day) in week.indexed) {
        cells.add((
          active != null && day == active,
          PositionedDirectional(
            key: ValueKey(day),
            start: margin + column * cell,
            top: CalendarMetrics.head + row * cell,
            width: cell,
            height: cell,
            child: dayBuilder(context, day, row),
          ),
        ));
      }
    }
    final grid = SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var column = 0; column < 7; column++)
            PositionedDirectional(
              start: margin + column * cell,
              top: 0,
              width: cell,
              height: CalendarMetrics.head,
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    formatters.weekdayName(
                      CalendarDates.addDays(weeks.first.first, column),
                    ),
                    style: type,
                  ),
                ),
              ),
            ),
          if (showWeekNumber)
            for (final (row, week) in weeks.indexed)
              PositionedDirectional(
                start: 0,
                top: CalendarMetrics.head + row * cell,
                width: margin,
                height: cell,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: CalendarMetrics.weekNumberEnd,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      formatters.weekNumber(
                        CalendarDates.weekNumber(week.first, weekStartsOn),
                      ),
                      style: type.merge(
                        theme.typography.face(
                          KevinSansFace.type,
                          cssSize: CalendarMetrics.weekNumberSize,
                          cssLineHeight: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          for (final (_, cell) in cells.where((entry) => !entry.$1)) cell,
          for (final (_, cell) in cells.where((entry) => entry.$1)) cell,
        ],
      ),
    );
    if (!ruled) return grid;
    final params = CalendarGridParams(
      rows: weeks.length,
      weekNumbers: showWeekNumber,
    );
    return InkSurface(
      source: RecipeInkSource(
        calendarGridRecipe,
        params,
        json: params.toJson(),
      ),
      seed: seed,
      still: true,
      child: grid,
    );
  }
}
