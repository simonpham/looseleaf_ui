import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/field/field.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Fields stacked 28 px apart (20 in calm, 16 when nested in another
/// group), filling the width. Its width switches responsive fields to a
/// row at 448 px, like upstream's container query.
///
/// Mirrors `FieldGroup` in upstream `src/components/ui/field.tsx`.
class FieldGroup extends StatelessWidget {
  const FieldGroup({super.key, required this.children, this.gap});

  /// The fields, sets and separators.
  final List<Widget> children;

  /// The space between fields, replacing 28 (20 calm, 16 nested), like
  /// upstream's `gap-*` classes; separators still pull in 8 on each side.
  final double? gap;

  /// `@md`: 28rem.
  static const double wideWidth = 448;

  /// `-my-2` around a [FieldSeparator].
  static const double _separatorPull = Spacing.d8;

  @override
  Widget build(BuildContext context) {
    final density = LooseleafTheme.of(context).density;
    final nested = FieldGroupScope.maybeOf(context) != null;
    final gap =
        this.gap ??
        switch ((nested, density)) {
          (true, _) => Spacing.d16,
          (false, LooseleafDensity.calm) => Spacing.d20,
          (false, _) => Spacing.d28,
        };
    return LayoutBuilder(
      builder: (context, constraints) => FieldGroupScope(
        wide: constraints.maxWidth >= wideWidth,
        child: FieldStack(
          gap: (index, before, after) => switch ((before, after)) {
            (FieldSeparator(), _) ||
            (_, FieldSeparator()) => gap - _separatorPull,
            _ => gap,
          },
          children: children,
        ),
      ),
    );
  }
}
