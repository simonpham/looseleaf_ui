import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/calendar_planner/calendar_planner.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One event on an index card's line: when, its dot and its title,
/// swiped with highlighter under the pointer or the keyboard. Opens the
/// event to change it.
///
/// Mirrors the row buttons of upstream
/// `src/blocks/calendar-planner/components/calendar-planner-agenda.tsx`.
class CalendarPlannerAgendaRow extends StatelessWidget {
  const CalendarPlannerAgendaRow({
    super.key,
    required this.when,
    required this.whenWidth,
    required this.whenAlign,
    required this.event,
    required this.spoken,
    required this.onOpen,
  });

  final String when;
  final double whenWidth;
  final TextAlign whenAlign;
  final CalendarPlannerEvent event;

  /// What a screen reader says after the title.
  final String spoken;
  final VoidCallback onOpen;

  static const double _height = 30;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return InkInteraction(
      onActivate: onOpen,
      semantics: SemanticsProperties(
        button: true,
        label: '${event.title}, $spoken. Open to change it.',
      ),
      builder: (context, states) => ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: switch (states.contains(InkState.hovered) ||
                states.contains(InkState.focused)) {
              true => theme.colors.hiSelect,
              false => null,
            },
          ),
          child: SizedBox(
            height: _height,
            child: Row(
              spacing: Spacing.d8,
              children: [
                SizedBox(
                  width: whenWidth,
                  child: Text(
                    when,
                    textAlign: whenAlign,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: theme.colors.inkSoft,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                CalendarPlannerDot(kind: event.kind),
                Expanded(
                  child: Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
