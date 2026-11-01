import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The look of a tab in a navigation strip: bold hand text 16 px in on a
/// pencil-sketched index tab, 36 px high (32 compact, 28 calm), washed
/// with highlighter under the pointer and lifted 2 px with an inked
/// outline while open ([NavTabRole.trigger]) or current
/// ([NavTabRole.link], filled). Show it for your own element that should
/// look like a tab; the triggers and strip links already do.
///
/// Mirrors upstream `navigationMenuTriggerStyle` and `navTabRecipe` in
/// `src/components/ui/navigation-menu.tsx`.
class NavigationMenuTab extends StatefulWidget {
  const NavigationMenuTab({
    super.key,
    required this.child,
    this.role = NavTabRole.link,
    this.states = const {},
    this.disabled = false,
    this.trailing,
    this.seed,
  });

  /// The label.
  final Widget child;

  /// A trigger lifts on `open`, a link on `checked`.
  final NavTabRole role;

  /// The states to show (`hover`, `focus`, `open`, `checked`, …).
  final Set<InkState> states;

  /// A dashed pencil tab in graphite.
  final bool disabled;

  /// A mark after the label (the trigger's chevron).
  final Widget? trailing;

  /// Pins the hand.
  final String? seed;

  @override
  State<NavigationMenuTab> createState() => _NavigationMenuTabState();
}

class _NavigationMenuTabState extends State<NavigationMenuTab> with InkSeed {
  static const ByDensity<double> _height = ByDensity(
    comfortable: Spacing.d36,
    compact: Spacing.d32,
    calm: Spacing.d28,
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final calm = theme.density == LooseleafDensity.calm;
    final params = NavTabParams(role: widget.role, disabled: widget.disabled);
    final source = RecipeInkSource(navTabRecipe, params, json: params.toJson());
    final lifted =
        widget.states.contains(InkState.open) ||
        widget.states.contains(InkState.checked);
    final lift = switch (lifted && !widget.disabled) {
      true => const Offset(0, -Spacing.d2),
      false => Offset.zero,
    };
    return TweenAnimationBuilder<Offset>(
      tween: Tween(end: lift),
      duration: InkMotion.of(context, InkMotion.hover),
      curve: InkMotion.settle,
      builder: (context, offset, child) =>
          Transform.translate(offset: offset, child: child),
      child: InkContent(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: switch (calm) {
            true => 14,
            false => 15,
          },
          cssLineHeight: switch (calm) {
            true => 20 / 14,
            false => null,
          },
          fontWeight: FontWeight.w700,
          color: switch (widget.disabled) {
            true => theme.colors.pencilText,
            false => theme.colors.ink,
          },
        ),
        iconSize: Spacing.d16,
        wrap: false,
        child: InkSurface(
          source: source,
          seed: inkSeed(widget.seed),
          states: {
            ...widget.states,
            if (widget.disabled) InkState.disabled,
          },
          still: true,
          child: SizedBox(
            height: _height.of(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d4,
                children: [widget.child, ?widget.trailing],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
