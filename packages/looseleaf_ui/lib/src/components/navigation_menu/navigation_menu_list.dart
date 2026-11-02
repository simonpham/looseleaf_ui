import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/navigation_menu/navigation_menu.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The row of tabs of a [NavigationMenu], 4 px apart, standing on a pencil
/// line, wrapping onto more rows when it is wider than its parent (the
/// `flex-wrap` upstream's demo puts on the list). Left and Right
/// (mirrored in RTL), Home and End walk them. A [NavigationMenuIndicator] among [children] hangs under the line instead
/// of joining the row.
///
/// Mirrors `NavigationMenuList` in upstream
/// `src/components/ui/navigation-menu.tsx`.
class NavigationMenuList extends StatefulWidget {
  const NavigationMenuList({super.key, required this.children, this.seed});

  /// [NavigationMenuItem]s, and optionally a [NavigationMenuIndicator].
  final List<Widget> children;

  /// Pins the line.
  final String? seed;

  @override
  State<NavigationMenuList> createState() => _NavigationMenuListState();
}

class _NavigationMenuListState extends State<NavigationMenuList> with InkSeed {
  static final RecipeInkSource<NoParams> _baseline = RecipeInkSource(
    navBaselineRecipe,
    const NoParams(),
    json: const NoParams().toJson(),
  );

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final child in widget.children)
        if (child is! NavigationMenuIndicator) child,
    ];
    final indicators = [
      for (final child in widget.children)
        if (child is NavigationMenuIndicator) child,
    ];
    return InkRovingFocus(
      axis: Axis.horizontal,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkSurface(
            source: _baseline,
            seed: inkSeed(widget.seed),
            still: true,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: Spacing.d4,
              runSpacing: Spacing.d4,
              children: items,
            ),
          ),
          for (final indicator in indicators)
            Positioned(
              left: 0,
              right: 0,
              bottom: -NavigationMenuIndicator.height,
              height: NavigationMenuIndicator.height,
              child: indicator,
            ),
        ],
      ),
    );
  }
}
