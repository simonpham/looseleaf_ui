import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The short sticker shadow a cloth ribbon casts (`--ll-drop-sticker`):
/// [child]'s own shape, blurred and offset down in the shade colour, under
/// [child]. Nothing is cast when [cast] is false or shadows are off.
///
/// Mirrors `RIBBON_SHADOW` in upstream `src/components/ui/bookmark.tsx`.
class BookmarkShadow extends StatelessWidget {
  const BookmarkShadow({super.key, required this.child, this.cast = true});

  static const List<({double dy, double blur, double alpha})> _drops = [
    (dy: 1, blur: 0.6, alpha: 0.26),
    (dy: 3, blur: 3, alpha: 0.14),
  ];

  /// The drawing that casts the shadow; painted again for each drop.
  final Widget child;

  /// Whether the shadow is cast.
  final bool cast;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    if (!cast || theme.shadowK <= 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final drop in _drops)
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Transform.translate(
                  offset: Offset(0, drop.dy),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: drop.blur / 2,
                      sigmaY: drop.blur / 2,
                    ),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        theme.colors.shade.withValues(
                          alpha: (drop.alpha * theme.shadowK).clamp(0.0, 1.0),
                        ),
                        BlendMode.srcIn,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
