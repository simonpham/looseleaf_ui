import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart' show MarkerTone;
import 'package:looseleaf_ui/src/components/marker/marker_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The icon at the start of a [Marker]: 16 px, red in a `fresh` marker
/// (icons through [IconTheme], text glyphs through [DefaultTextStyle]).
/// Decorative.
///
/// Mirrors `MarkerIcon` in upstream `src/components/ui/marker.tsx`.
class MarkerIcon extends StatelessWidget {
  const MarkerIcon({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fresh = MarkerScope.maybeOf(context)?.tone == MarkerTone.fresh;
    final color = switch (fresh) {
      true => LooseleafTheme.of(context).colors.red,
      false => null,
    };
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: Spacing.d16,
        child: IconTheme.merge(
          data: IconThemeData(size: Spacing.d16, color: color),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: color),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
