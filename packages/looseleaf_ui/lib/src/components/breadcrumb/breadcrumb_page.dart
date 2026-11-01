import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The page you are on: bold, and underlined twice in blue felt. Not a
/// link; screen readers hear it as the current page.
///
/// Mirrors `BreadcrumbPage` in upstream `src/components/ui/breadcrumb.tsx`.
class BreadcrumbPage extends StatefulWidget {
  const BreadcrumbPage({super.key, required this.child, this.seed});

  final Widget child;

  /// Pins the hand: the same seed always draws the same underline.
  final String? seed;

  @override
  State<BreadcrumbPage> createState() => _BreadcrumbPageState();
}

class _BreadcrumbPageState extends State<BreadcrumbPage> with InkSeed {
  static final _source = RecipeInkSource(
    breadcrumbPageRecipe,
    const NoParams(),
    json: const NoParams().toJson(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      link: true,
      enabled: false,
      selected: true,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontWeight: FontWeight.w700, color: theme.colors.ink),
        child: InkSurface(
          source: _source,
          seed: inkSeed(widget.seed),
          still: true,
          child: Padding(
            padding: const EdgeInsets.only(
              left: Spacing.d2,
              right: Spacing.d2,
              bottom: Spacing.d4,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
