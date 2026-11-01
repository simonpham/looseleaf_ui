import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/toggle/toggle_metrics.dart';
import 'package:looseleaf_ui/src/components/toggle/without_part_ink_source.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The drawing and content of a toggle, shared by [Toggle] and
/// [ToggleGroupItem]: the toggle recipe behind a bold Kevin Sans Hand
/// label, sized by [size], sinking a pixel while pressed.
///
/// Mirrors the `toggleVariants` classes of upstream
/// `src/components/ui/toggle.tsx`.
class ToggleSurface extends StatelessWidget {
  const ToggleSurface({
    super.key,
    required this.params,
    required this.seed,
    required this.states,
    required this.size,
    required this.child,
    this.leading,
    this.padding,
    this.minWidth,
    this.hiddenPart,
  });

  /// The toggle recipe params.
  final ToggleParams params;

  final String seed;
  final Set<InkState> states;
  final ToggleSize size;

  /// The inline padding; [ToggleSize.padding] when null.
  final double? padding;

  /// The least width; the height (`min-w-*`) when null.
  final double? minWidth;

  /// A `data-part` of the drawing left out, like a joined group's first
  /// seam.
  final String? hiddenPart;

  final Widget child;

  /// An icon before [child], 8 px from it (`gap-2`).
  final Widget? leading;

  InkSource get _source {
    final source = RecipeInkSource(
      toggleRecipe,
      params,
      json: params.toJson(),
    );
    return switch (hiddenPart) {
      final part? => WithoutPartInkSource(source, part),
      null => source,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final height = size.height.resolve(theme.density);
    final pressed = states.contains(InkState.pressed);
    return TweenAnimationBuilder<double>(
      tween: Tween(
        end: switch (pressed) {
          true => InkMotion.pressSink,
          false => 0,
        },
      ),
      duration: InkMotion.of(context, InkMotion.press),
      curve: InkMotion.easeOut,
      builder: (context, sink, child) =>
          Transform.translate(offset: Offset(0, sink), child: child),
      child: InkContent(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: size.cssFontSize,
          cssLineHeight: size.cssLineHeight,
          fontWeight: FontWeight.w700,
          color: switch (params.disabled) {
            true => theme.colors.pencilText,
            false => theme.colors.ink,
          },
        ),
        iconSize: Spacing.d16,
        wrap: false,
        child: InkSurface(
          source: _source,
          seed: seed,
          states: states,
          sinkSelf: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth ?? height),
            child: SizedBox(
              height: height,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding ?? size.padding,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: Spacing.d8,
                  children: [
                    ?leading,
                    Flexible(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
