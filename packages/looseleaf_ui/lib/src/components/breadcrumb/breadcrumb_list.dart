import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The trail of a [Breadcrumb]: items and separators in a wrapping row of
/// muted hand text.
///
/// Mirrors `BreadcrumbList` in upstream `src/components/ui/breadcrumb.tsx`.
class BreadcrumbList extends StatelessWidget {
  const BreadcrumbList({super.key, required this.children});

  final List<Widget> children;

  /// Tailwind's `sm` breakpoint, from where the gap grows to 8.
  static const double smallWidth = 640;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final wide = (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= smallWidth;
    final gap = switch (wide) {
      true => Spacing.d8,
      false => Spacing.d6,
    };
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 16,
        cssLineHeight: 1.5,
        color: theme.colors.inkMuted,
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: gap,
        runSpacing: gap,
        children: children,
      ),
    );
  }
}
