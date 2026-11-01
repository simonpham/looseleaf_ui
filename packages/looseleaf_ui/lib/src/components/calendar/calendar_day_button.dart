import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_day_painter.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_focus_painter.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_metrics.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_tiles.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_today_painter.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One day of a [Calendar]: its number in script with the marks that say
/// what it is: circled in marker when chosen, one cell of a highlighter
/// swipe in a range (bold at the ends), underlined in felt today, hatched
/// in pencil when it cannot be picked, a blue loop round it under the
/// keyboard.
///
/// Mirrors `CalendarDayButton` in upstream
/// `src/components/ui/calendar.tsx` with the day rules of `calendarCss`.
class CalendarDayButton extends StatelessWidget {
  const CalendarDayButton({
    super.key,
    required this.day,
    required this.child,
    this.onPressed,
    this.size = Spacing.d40,
    this.chosen = false,
    this.band,
    this.bandFrame = 0,
    this.today = false,
    this.outside = false,
    this.disabled = false,
    this.selected = false,
    this.focusNode,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The day shown.
  final DateTime day;

  /// The number, usually a [Text].
  final Widget child;

  /// Called on tap, Enter and Space.
  final VoidCallback? onPressed;

  /// The cell's side (`--cell`).
  final double size;

  /// The single chosen day: wash, ring and bold.
  final bool chosen;

  /// This day's cell of a range swipe; bold at the ends.
  final CalendarBandKind? band;

  /// Which band frame, alternating by week.
  final int bandFrame;

  /// Underlined in felt, `aria-current="date"`.
  final bool today;

  /// A day of a neighbouring month: graphite and not bold.
  final bool outside;

  /// Hatched out, graphite, no input.
  final bool disabled;

  /// Chosen in any mode, for screen readers.
  final bool selected;

  final FocusNode? focusNode;

  /// The accessible name: the full date.
  final String? semanticLabel;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  bool get _bold =>
      chosen ||
      switch (band) {
        CalendarBandKind.start ||
        CalendarBandKind.end ||
        CalendarBandKind.pill => true,
        _ => false,
      };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final mirror = Directionality.of(context) == TextDirection.rtl;
    final hand = day.day % ringHands;
    final weight = switch ((outside, _bold)) {
      (_, true) => FontWeight.w700,
      (true, false) => FontWeight.w400,
      (false, false) => FontWeight.w600,
    };
    final style = theme.typography.face(
      KevinSansFace.script,
      cssSize: CalendarMetrics.daySize(theme.density),
      cssLineHeight: 1,
      fontWeight: weight,
      color: switch (outside || disabled) {
        true => colors.pencilText,
        false => colors.ink,
      },
    );
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      enabled: !disabled,
      label: semanticLabel,
      child: InkInteraction(
        enabled: !disabled,
        onActivate: onPressed,
        focusNode: focusNode,
        states: forcedStates,
        mouseCursor: SystemMouseCursors.basic,
        disabledMouseCursor: SystemMouseCursors.forbidden,
        builder: (context, states) {
          final hovered =
              states.contains(InkState.hovered) && band == null && !chosen;
          return SizedBox.square(
            dimension: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: CalendarDayPainter(
                      theme: theme,
                      hand: hand,
                      band: band,
                      bandFrame: bandFrame,
                      mirror: mirror,
                      chosen: chosen,
                      hatched: disabled,
                      hovered: hovered,
                    ),
                  ),
                ),
                Center(
                  child: ExcludeSemantics(
                    child: DefaultTextStyle(
                      style: style,
                      textAlign: TextAlign.center,
                      child: child,
                    ),
                  ),
                ),
                if (today)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(CalendarMetrics.dayInset),
                      child: CustomPaint(
                        painter: CalendarTodayPainter(theme: theme, hand: hand),
                      ),
                    ),
                  ),
                if (states.contains(InkState.focused))
                  Positioned.fill(
                    left: -CalendarMetrics.focusReach,
                    top: -CalendarMetrics.focusReach,
                    right: -CalendarMetrics.focusReach,
                    bottom: -CalendarMetrics.focusReach,
                    child: CustomPaint(
                      painter: CalendarFocusPainter(theme: theme),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
