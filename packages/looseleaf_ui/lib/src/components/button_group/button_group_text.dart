import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A printed cell in a [ButtonGroup]: a shaded wash in an inked box holding
/// a label, a unit or a value (`https://`, `250`, `grams`).
///
/// Mirrors `ButtonGroupText` in upstream
/// `src/components/ui/button-group.tsx` (`min-h-9 px-4 gap-2 font-hand
/// text-base`).
class ButtonGroupText extends StatefulWidget {
  const ButtonGroupText({
    super.key,
    required this.child,
    this.leading,
    this.alignment = MainAxisAlignment.start,
    this.minWidth = 0,
    this.seed,
  });

  /// The text.
  final Widget child;

  /// An icon before the text, 16 px.
  final Widget? leading;

  /// Where the content sits, like `justify-center` on a value cell.
  final MainAxisAlignment alignment;

  /// The cell's smallest width (`min-w-*`).
  final double minWidth;

  /// Pins the hand.
  final String? seed;

  @override
  State<ButtonGroupText> createState() => _ButtonGroupTextState();
}

class _ButtonGroupTextState extends State<ButtonGroupText> with InkSeed {
  static const _height = ByDensity(
    comfortable: Spacing.d36,
    compact: Spacing.d32,
    calm: Spacing.d28,
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    const params = NoParams();
    return InkContent(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 16,
        cssLineHeight: 1.5,
        color: theme.colors.ink,
      ),
      iconSize: Spacing.d16,
      wrap: false,
      child: InkSurface(
        source: RecipeInkSource(buttonGroupTextRecipe, params),
        seed: inkSeed(widget.seed),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: _height.resolve(theme.density),
            minWidth: widget.minWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.alignment,
              spacing: Spacing.d8,
              children: [
                ?widget.leading,
                Flexible(child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
