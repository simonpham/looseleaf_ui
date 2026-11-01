import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A data cell: padded 12 by 8, on one line.
///
/// Named `InkTableCell` because Flutter's widgets library has a
/// `TableCell`. Mirrors `TableCell` in upstream
/// `src/components/ui/table.tsx`.
class InkTableCell extends StatelessWidget {
  const InkTableCell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.d12,
      vertical: Spacing.d8,
    ),
    child: DefaultTextStyle.merge(softWrap: false, child: child),
  );
}
