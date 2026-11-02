import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/calendar_planner/calendar_planner.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A small coloured dot that says what sort an event is.
///
/// Mirrors `Dot` in upstream
/// `src/blocks/calendar-planner/components/calendar-planner-agenda.tsx`.
class CalendarPlannerDot extends StatelessWidget {
  const CalendarPlannerDot({super.key, required this.kind});

  final CalendarPlannerKind kind;

  static const double _ringAlpha = 0.4;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: Spacing.d10,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: kind.dot(colors),
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.ink.withValues(alpha: _ringAlpha),
              width: Spacing.d1,
            ),
          ),
        ),
      ),
    );
  }
}
