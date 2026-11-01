import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The photo window of a hover card: a 112 px shaded well in a pencil
/// frame, its [child] (a doodle, a sticker, an image) centred 8 px in.
///
/// Mirrors `HoverCardMedia` in upstream `src/components/ui/hover-card.tsx`.
class HoverCardMedia extends StatefulWidget {
  const HoverCardMedia({
    super.key,
    this.child,
    this.height = defaultHeight,
    this.seed,
  });

  /// Upstream's `h-28`.
  static const double defaultHeight = Spacing.d112;

  /// What the window shows; an image fills it.
  final Widget? child;

  /// The window's height.
  final double height;

  /// Pins the frame.
  final String? seed;

  @override
  State<HoverCardMedia> createState() => _HoverCardMediaState();
}

class _HoverCardMediaState extends State<HoverCardMedia> with InkSeed {
  static final RecipeInkSource<NoParams> _frame = RecipeInkSource(
    hoverCardMediaRecipe,
    const NoParams(),
    json: const NoParams().toJson(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      height: widget.height,
      child: ColoredBox(
        color: theme.colors.paperShade.withValues(alpha: 0.6),
        child: InkSurface(
          source: _frame,
          seed: inkSeed(widget.seed),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.d8),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
