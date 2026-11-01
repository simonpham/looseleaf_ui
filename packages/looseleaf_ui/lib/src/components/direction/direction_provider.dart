import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Sets which way everything below reads: Flutter's [Directionality] (text,
/// layout, arrow keys) and the [LooseleafTheme]'s direction (the ink
/// engine, so hand-drawn strokes, tab shoulders and slider edges turn round
/// with it).
///
/// Without a [direction] it follows the ambient [Directionality] and only
/// hands it on to the ink.
///
/// ```dart
/// DirectionProvider(direction: TextDirection.rtl, child: page)
/// ```
///
/// Mirrors `DirectionProvider` in upstream `src/components/ui/direction.tsx`.
class DirectionProvider extends StatelessWidget {
  const DirectionProvider({super.key, this.direction, required this.child});

  /// The reading direction; null follows the ambient one.
  final TextDirection? direction;

  final Widget child;

  /// The reading direction here: [local] when given (a direction prop of
  /// your own widget wins), else the nearest [Directionality], else
  /// [TextDirection.ltr]. Upstream `useDirection`.
  static TextDirection of(BuildContext context, [TextDirection? local]) =>
      local ?? Directionality.maybeOf(context) ?? TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    final value = direction ?? of(context);
    final theme = LooseleafTheme.of(context);
    return Directionality(
      textDirection: value,
      child: LooseleafTheme(
        data: theme.copyWith(textDirection: value),
        child: child,
      ),
    );
  }
}
