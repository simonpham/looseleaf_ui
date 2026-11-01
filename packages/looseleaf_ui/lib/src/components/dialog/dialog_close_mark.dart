import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// The doodled × in a dialog's or sheet's corner: an inked cross in a
/// 32 px box, a highlighter blot on hover and a round focus ring, announced
/// as a "Close" button. It closes the nearest [Dialog] (or alert dialog,
/// sheet, drawer) unless [onPressed] is given.
///
/// Mirrors `DialogCloseMark` in upstream `src/components/ui/dialog.tsx`
/// (`closeMarkRecipe` of `src/lib/ink/recipes/overlay-ink.ts`).
class DialogCloseMark extends StatefulWidget {
  const DialogCloseMark({
    super.key,
    this.onPressed,
    this.tone,
    this.seed,
    this.semanticLabel = 'Close',
    this.focusNode,
    this.forcedStates = const {},
  });

  /// Called on tap, Enter and Space; closes the dialog when null.
  final VoidCallback? onPressed;

  /// The cross's ink; ink when null.
  final CloseMarkTone? tone;

  /// Pins the cross.
  final String? seed;

  /// What screen readers call it.
  final String semanticLabel;

  /// The button's focus node.
  final FocusNode? focusNode;

  /// States to show regardless of input, for state grids.
  final Set<InkState> forcedStates;

  @override
  State<DialogCloseMark> createState() => _DialogCloseMarkState();
}

class _DialogCloseMarkState extends State<DialogCloseMark> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final params = CloseMarkParams(tone: widget.tone);
    final source = RecipeInkSource(
      closeMarkRecipe,
      params,
      json: params.toJson(),
    );
    final press = widget.onPressed ?? DialogScope.maybeOf(context)?.close;
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: widget.semanticLabel,
      child: InkInteraction(
        onActivate: press,
        focusNode: widget.focusNode,
        states: widget.forcedStates,
        builder: (context, states) => InkSurface(
          source: source,
          seed: inkSeed(widget.seed),
          states: states,
          child: const SizedBox.square(dimension: DialogMetrics.closeSize),
        ),
      ),
    );
  }
}
