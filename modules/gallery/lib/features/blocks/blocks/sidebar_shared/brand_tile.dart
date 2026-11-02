import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A marker-yellow square with a lopsided hand-cut corner and an icon:
/// the app's mark in a sidebar row.
///
/// Mirrors `BrandTile` in upstream `src/blocks/sidebar-shared/sidebar-brand.tsx`.
class BrandTile extends StatelessWidget {
  const BrandTile({super.key, required this.icon, this.small = false});

  final String icon;

  /// 20 px instead of 32.
  final bool small;

  static const _corners = BorderRadius.only(
    topLeft: Radius.elliptical(Spacing.d3, Spacing.d8),
    topRight: Radius.elliptical(Spacing.d8, Spacing.d3),
    bottomRight: Radius.elliptical(Spacing.d4, Spacing.d9),
    bottomLeft: Radius.elliptical(Spacing.d9, Spacing.d4),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox.square(
      dimension: switch (small) {
        true => Spacing.d20,
        false => Spacing.d32,
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.marker.withValues(alpha: 0.8),
          borderRadius: _corners,
        ),
        child: Center(
          child: InkIcon(
            icon,
            color: theme.colors.ink,
            size: switch (small) {
              true => Spacing.d12,
              false => Spacing.d16,
            },
          ),
        ),
      ),
    );
  }
}
