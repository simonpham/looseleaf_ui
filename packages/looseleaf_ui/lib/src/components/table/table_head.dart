import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Which way a column is sorted, for [TableHead.sort].
enum TableSort { ascending, descending }

/// A column title: blue-ink script (bold hand text in calm density), ink
/// when the column is sorted.
///
/// Mirrors `TableHead` in upstream `src/components/ui/table.tsx`.
class TableHead extends StatelessWidget {
  const TableHead({super.key, required this.child, this.sort});

  final Widget child;

  /// Marks the column sorted (upstream `aria-sort`).
  final TableSort? sort;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final calm = theme.density == LooseleafDensity.calm;
    final style = switch (calm) {
      true => theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 20 / 14,
        fontWeight: FontWeight.w700,
        color: colors.inkSoft,
      ),
      false => theme.typography.face(
        KevinSansFace.script,
        cssSize: 19,
        cssLineHeight: 1,
        fontWeight: FontWeight.w600,
        color: switch (sort) {
          null => colors.inkYou,
          _ => colors.ink,
        },
      ),
    };
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.d12),
        child: DefaultTextStyle.merge(
          style: style,
          softWrap: false,
          child: child,
        ),
      ),
    );
  }
}
