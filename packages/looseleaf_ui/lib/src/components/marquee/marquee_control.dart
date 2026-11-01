import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/marquee/marquee.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A marquee's pause button: a 28 px ringed disc with two bars, or a
/// triangle while paused; a toggle button named `Pause ticker`. A [Marquee]
/// includes one; place your own only inside a marquee.
///
/// Mirrors `MarqueeControl` in upstream `src/components/ui/marquee.tsx`.
class MarqueeControl extends StatefulWidget {
  const MarqueeControl({
    super.key,
    this.onPressed,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel = 'Pause ticker',
    this.forcedStates = const {},
  });

  /// The button's side.
  static const double size = Spacing.d28;

  /// Called before the marquee toggles.
  final VoidCallback? onPressed;

  /// Pins the hand.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name.
  final String semanticLabel;

  /// States shown whatever the input: for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<MarqueeControl> createState() => _MarqueeControlState();
}

class _MarqueeControlState extends State<MarqueeControl> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final scope = MarqueeScope.of(context);
    final params = MarqueeControlParams(paused: scope.paused);
    final source = RecipeInkSource(
      marqueeControlRecipe,
      params,
      json: params.toJson(),
    );
    return Semantics(
      container: true,
      button: true,
      toggled: scope.paused,
      label: widget.semanticLabel,
      child: InkInteraction(
        onActivate: () {
          widget.onPressed?.call();
          scope.onToggle();
        },
        states: widget.forcedStates,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        builder: (context, states) => InkSurface(
          source: source,
          seed: inkSeed(widget.seed),
          states: states,
          child: const SizedBox.square(dimension: MarqueeControl.size),
        ),
      ),
    );
  }
}
