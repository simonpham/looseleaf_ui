import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/bookmark/bookmark.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A cloth ribbon hanging as a page marker, 32 × 56 px: woven,
/// edge-stitched, swallowtail-notched, casting a short shadow, turned a
/// seeded hair off straight (at most 1.4°, flat when calm). Decorative and
/// ignores input; place it over the top edge of a sheet in a [Stack].
///
/// ```dart
/// const Positioned(
///   top: -Spacing.d4,
///   right: Spacing.d24,
///   child: BookmarkRibbon(tone: Accent.grape),
/// )
/// ```
///
/// Mirrors `BookmarkRibbon` in upstream `src/components/ui/bookmark.tsx`.
class BookmarkRibbon extends StatefulWidget {
  const BookmarkRibbon({
    super.key,
    this.tone = Accent.tomato,
    this.width = Spacing.d32,
    this.height = Spacing.d56,
    this.tilt = true,
    this.tiltDegrees,
    this.seed,
  });

  /// The ribbon's colour.
  final Accent tone;

  /// The ribbon's width; upstream's `w-8`.
  final double width;

  /// The ribbon's length; upstream's `h-14`.
  final double height;

  /// False hangs it straight.
  final bool tilt;

  /// A fixed turn in degrees; seeded within 1.4° when null.
  final double? tiltDegrees;

  /// Pins the weave, the stitching and the turn.
  final String? seed;

  @override
  State<BookmarkRibbon> createState() => _BookmarkRibbonState();
}

class _BookmarkRibbonState extends State<BookmarkRibbon> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, Bookmark.tiltMax),
    };
    final params = BookmarkParams(
      tone: widget.tone,
      mode: BookmarkMode.fixed,
      disabled: false,
    );
    return ExcludeSemantics(
      child: IgnorePointer(
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Transform.rotate(
            angle: PaperInk.tilt(context, degrees),
            child: BookmarkShadow(
              child: InkSurface(
                source: RecipeInkSource(
                  bookmarkRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: seed,
                still: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
