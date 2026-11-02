import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A column head that sorts the table: its label and an arrow showing
/// which way, or both ways when another column sorts.
class DashboardFinanceSortHead extends StatelessWidget {
  const DashboardFinanceSortHead({
    super.key,
    required this.label,
    required this.sort,
    required this.onSort,
    this.end = false,
  });

  final String label;

  /// This column's direction; null when another column sorts.
  final TableSort? sort;
  final VoidCallback onSort;

  /// Sits at the end of its cell, like a number column's head.
  final bool end;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final button = Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.sm,
      onPressed: onSort,
      trailing: InkIcon(switch (sort) {
        TableSort.ascending => 'arrow-up',
        TableSort.descending => 'arrow-down',
        null => 'arrow-up-down',
      }, size: Spacing.d14),
      child: Text(
        label,
        style: theme.typography.face(KevinSansFace.script, cssSize: 19),
      ),
    );
    return TableHead(
      sort: sort,
      child: Align(
        alignment: switch (end) {
          true => AlignmentDirectional.centerEnd,
          false => AlignmentDirectional.centerStart,
        },
        child: button,
      ),
    );
  }
}
