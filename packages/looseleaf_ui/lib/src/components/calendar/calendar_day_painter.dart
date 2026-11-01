import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_metrics.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_tiles.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The marks under a day's number, the cell's `::before` / `::after`
/// rules of upstream `calendarCss`: the range swipe across the cell, the
/// hover wash, the marker wash and ring of a chosen day, the hatch of a
/// disabled one.
class CalendarDayPainter extends CustomPainter {
  const CalendarDayPainter({
    required this.theme,
    required this.hand,
    this.band,
    this.bandFrame = 0,
    this.mirror = false,
    this.chosen = false,
    this.hatched = false,
    this.hovered = false,
  });

  final LooseleafThemeData theme;

  /// The hand that draws the marks: the day of the month modulo
  /// [ringHands] (upstream `data-v`).
  final int hand;

  /// The range band through the cell, or null.
  final CalendarBandKind? band;

  /// Which band frame: alternates by week row.
  final int bandFrame;

  /// Right to left: the band's caps turn round.
  final bool mirror;

  /// A single chosen day: the wash and the ring.
  final bool chosen;

  /// A disabled day: the pencil hatch.
  final bool hatched;

  /// The `@media (hover:hover)` highlighter behind the day.
  final bool hovered;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = theme.colors;
    final tiles = CalendarTiles.instance;
    final cell = Offset.zero & size;
    final button = cell.deflate(CalendarMetrics.dayInset);
    if (band case final kind?) {
      CalendarTiles.mask(
        canvas,
        theme,
        tiles.bands[bandFrame % bandFrames][kind] ??
            tiles.bands[0].values.first,
        const Size(calendarCell, calendarCell - 12),
        Rect.fromLTRB(
          0,
          CalendarMetrics.bandInset,
          size.width,
          size.height - CalendarMetrics.bandInset,
        ),
        colors.hiSelect,
        mirror: mirror,
      );
    }
    if (hovered) {
      canvas.drawRRect(
        CalendarMetrics.hoverRadius.toRRect(button),
        Paint()..color = colors.hiSelect,
      );
    }
    if (hatched) {
      CalendarTiles.mask(
        canvas,
        theme,
        tiles.hatch,
        const Size.square(hatchSize),
        button.deflate(CalendarMetrics.hatchInset),
        colors.pencilMark.withValues(alpha: colors.pencilMark.a * 0.55),
      );
    }
    if (!chosen) return;
    final index = hand % ringHands;
    CalendarTiles.mask(
      canvas,
      theme,
      tiles.washes[index],
      const Size.square(calendarCell),
      button,
      colors.marker.withValues(alpha: colors.marker.a * 0.26),
    );
    CalendarTiles.mask(
      canvas,
      theme,
      tiles.rings[index],
      const Size.square(calendarCell),
      button.inflate(CalendarMetrics.ringReach),
      colors.marker.withValues(alpha: colors.marker.a * 0.92),
    );
  }

  @override
  bool shouldRepaint(CalendarDayPainter oldDelegate) =>
      oldDelegate.theme != theme ||
      oldDelegate.hand != hand ||
      oldDelegate.band != band ||
      oldDelegate.bandFrame != bandFrame ||
      oldDelegate.mirror != mirror ||
      oldDelegate.chosen != chosen ||
      oldDelegate.hatched != hatched ||
      oldDelegate.hovered != hovered;
}
