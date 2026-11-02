import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/table/table.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A data cell: padded 12 by 8 (or [padding]), on one line unless [wrap]
/// is set.
///
/// Named `InkTableCell` because Flutter's widgets library has a
/// `TableCell`. Mirrors `TableCell` in upstream
/// `src/components/ui/table.tsx`.
class InkTableCell extends StatelessWidget {
  const InkTableCell({
    super.key,
    required this.child,
    this.wrap = false,
    this.colSpan = 1,
    this.padding = defaultPadding,
  });

  /// Upstream's `px-3 py-2`.
  static const EdgeInsetsGeometry defaultPadding = EdgeInsets.symmetric(
    horizontal: Spacing.d12,
    vertical: Spacing.d8,
  );

  final Widget child;

  /// Lets long text wrap (upstream `whitespace-normal`): the table then
  /// narrows this column to fit its space before it scrolls sideways.
  final bool wrap;

  /// How many columns the cell covers (upstream `colSpan`). A spanning
  /// cell stays on one line and never widens the columns it covers.
  final int colSpan;

  /// The room round the content, for a cell that overrides upstream's
  /// `px-3 py-2` (a tight checkbox column, a roomy notes cell).
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: switch (wrap) {
      true => child,
      false => TableNoWrap(
        child: DefaultTextStyle.merge(softWrap: false, child: child),
      ),
    },
  );
}
