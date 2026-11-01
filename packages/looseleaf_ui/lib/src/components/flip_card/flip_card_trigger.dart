import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/flip_card/flip_card_scope.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Turns its [FlipCard] over. By default ([overlay]) it is an invisible
/// button over the whole card with a pencil "flip me" arrow in the corner
/// that inks in on hover and a drawn focus ring; Space and Enter press it.
/// A [FlipCard] adds one itself unless `trigger: false`.
///
/// With `overlay: false` it draws nothing and hands [builder] the toggle,
/// for a button of your own (upstream `asChild`):
///
/// ```dart
/// FlipCardTrigger(
///   overlay: false,
///   builder: (context, toggle) => Button(
///     variant: .link,
///     size: .sm,
///     onPressed: toggle,
///     child: const Text('Details'),
///   ),
/// )
/// ```
///
/// Mirrors `FlipCardTrigger` in upstream `src/components/ui/flip-card.tsx`.
class FlipCardTrigger extends StatefulWidget {
  const FlipCardTrigger({
    super.key,
    this.overlay = true,
    this.hint,
    this.builder,
    this.onPressed,
    this.semanticLabel,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// Covers the card as its button; false hands [builder] the toggle.
  final bool overlay;

  /// Draws the corner arrow; true when null.
  final bool? hint;

  /// Builds your own trigger around the card's toggle.
  final Widget Function(BuildContext context, VoidCallback toggle)? builder;

  /// Called before the card turns.
  final VoidCallback? onPressed;

  /// The button's name; the card's `label` when null.
  final String? semanticLabel;

  /// Pins the hand.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<FlipCardTrigger> createState() => _FlipCardTriggerState();
}

class _FlipCardTriggerState extends State<FlipCardTrigger> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final scope = FlipCardScope.of(context);
    void toggle() {
      widget.onPressed?.call();
      scope.toggle();
    }

    if (!widget.overlay) {
      return widget.builder?.call(context, toggle) ?? const SizedBox.shrink();
    }
    final params = FlipTriggerParams(hint: widget.hint ?? true);
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      toggled: scope.flipped,
      label: widget.semanticLabel ?? scope.label,
      child: InkInteraction(
        onActivate: toggle,
        states: widget.forcedStates,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        builder: (context, states) => InkSurface(
          source: RecipeInkSource(
            flipTriggerRecipe,
            params,
            json: params.toJson(),
          ),
          seed: inkSeed(widget.seed),
          states: states,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
