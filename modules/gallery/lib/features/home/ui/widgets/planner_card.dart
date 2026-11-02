import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A taped calendar sheet: this month, days before today crossed out, a
/// day three days ahead picked.
///
/// Mirrors `Planner` in upstream `src/docs/content/home/planner.tsx`.
class PlannerCard extends StatefulWidget {
  const PlannerCard({super.key});

  @override
  State<PlannerCard> createState() => _PlannerCardState();
}

class _PlannerCardState extends State<PlannerCard> {
  late final DateTime _today = _dayOf(DateTime.now());
  late DateTime? _picked = DateTime(
    _today.year,
    _today.month,
    _today.day + 3,
  );

  static DateTime _dayOf(DateTime moment) =>
      DateTime(moment.year, moment.month, moment.day);

  @override
  Widget build(BuildContext context) => Center(
    child: Calendar(
      selected: _picked,
      onSelect: (day) => setState(() => _picked = day),
      today: _today,
      defaultMonth: _today,
      isDateDisabled: (day) => day.isBefore(_today),
      sheet: const CalendarSheet(
        stock: StockName.card,
        tape: PaperTape.corner,
        seed: 'home-planner',
      ),
      seed: 'home-planner',
    ),
  );
}
