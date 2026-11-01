import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_tiles.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Today's felt underline under the number, upstream's
/// `[data-part=today]` (`left:18%; right:18%; bottom:11%; height:22%` of
/// the day button).
class CalendarTodayPainter extends CustomPainter {
  const CalendarTodayPainter({required this.theme, required this.hand});

  final LooseleafThemeData theme;

  /// The day of the month modulo [ringHands]: hands 1 and 2 draw their
  /// own underline, the rest the first.
  final int hand;

  @override
  void paint(Canvas canvas, Size size) {
    final tiles = CalendarTiles.instance;
    final index = switch (hand % ringHands) {
      final own when own > 0 && own < underlineHands => own,
      _ => 0,
    };
    CalendarTiles.mask(
      canvas,
      theme,
      tiles.underlines[index],
      const Size(calendarCell, 10),
      Rect.fromLTRB(
        size.width * 0.18,
        size.height * (1 - 0.11 - 0.22),
        size.width * 0.82,
        size.height * (1 - 0.11),
      ),
      theme.colors.inkYou,
    );
  }

  @override
  bool shouldRepaint(CalendarTodayPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.hand != hand;
}
