import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_tiles.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The drawn blue loop round a keyboard-focused day, upstream's
/// `td:has(>button:focus-visible)::after`; paint it over the cell grown
/// by `CalendarMetrics.focusReach`.
class CalendarFocusPainter extends CustomPainter {
  const CalendarFocusPainter({required this.theme});

  final LooseleafThemeData theme;

  @override
  void paint(Canvas canvas, Size size) => CalendarTiles.mask(
    canvas,
    theme,
    CalendarTiles.instance.focus,
    const Size.square(focusTileSize),
    Offset.zero & size,
    theme.colors.focus,
  );

  @override
  bool shouldRepaint(CalendarFocusPainter oldDelegate) =>
      oldDelegate.theme != theme;
}
