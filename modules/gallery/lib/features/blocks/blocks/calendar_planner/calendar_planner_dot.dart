import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/calendar_planner/calendar_planner.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A small coloured dot that says what sort an event is.
///
/// Mirrors `Dot` in upstream
/// `src/blocks/calendar-planner/components/calendar-planner-agenda.tsx`.
class CalendarPlannerDot extends StatelessWidget {
  const CalendarPlannerDot({
    super.key,
    required this.kind,
    this.size = Spacing.d10,
    this.ringed = true,
  });

  final CalendarPlannerKind kind;

  /// The dot's diameter.
  final double size;

  /// Draws the faint ink ring; off for the dots under a calendar day.
  final bool ringed;

  static const double _ringAlpha = 0.4;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: kind.dot(colors),
            shape: BoxShape.circle,
            border: switch (ringed) {
              true => Border.all(
                color: colors.ink.withValues(alpha: _ringAlpha),
                width: Spacing.d1,
              ),
              false => null,
            },
          ),
        ),
      ),
    );
  }
}
