import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart' show MarkerTone;
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/marker/marker_scope.dart';
import 'package:looseleaf_ui/src/components/marker/marker_variant.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The words of a [Marker]. In a separator they are script, centered and
/// never squeezed; in a `fresh` marker they are bold on a highlighter
/// swipe.
///
/// Mirrors `MarkerContent` in upstream `src/components/ui/marker.tsx`.
class MarkerContent extends StatelessWidget {
  const MarkerContent({super.key, required this.child});

  /// Usually a [Text].
  final Widget child;

  /// `ll-swipe`'s border radius: `3px 8px 4px 9px / 8px 3px 9px 4px`.
  static const BorderRadius swipeRadius = BorderRadius.only(
    topLeft: Radius.elliptical(3, 8),
    topRight: Radius.elliptical(8, 3),
    bottomRight: Radius.elliptical(4, 9),
    bottomLeft: Radius.elliptical(9, 4),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final scope = MarkerScope.maybeOf(context);
    final separator = scope?.variant == MarkerVariant.separator;
    final fresh = scope?.tone == MarkerTone.fresh;
    final base = switch (separator) {
      true => theme.typography.face(
        KevinSansFace.script,
        cssSize: 20,
        cssLineHeight: 1,
      ),
      false => const TextStyle(),
    };
    final style = switch (fresh) {
      true => base.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colors.selectionText,
      ),
      false => base,
    };
    final text = InkContent(
      style: style,
      child: switch (separator) {
        true => DefaultTextStyle.merge(
          textAlign: TextAlign.center,
          child: child,
        ),
        false => child,
      },
    );
    if (!fresh) return text;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.hiSelect,
        borderRadius: swipeRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
        child: text,
      ),
    );
  }
}
