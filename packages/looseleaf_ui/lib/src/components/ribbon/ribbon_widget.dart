import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/ribbon/ribbon_metrics.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A band of colored paper with real words on it: a [RibbonVariant.banner]
/// with folded tails, a [RibbonVariant.swallow] notched at both ends, or a
/// [RibbonVariant.flag] square at the start. The paper is drawn behind the
/// label and grows with it.
///
/// With [onPressed] the ribbon is a button (upstream's `asChild` link or
/// button): hover lifts it a pixel, draws a drop line and underlines the
/// words; keyboard focus rings the whole ribbon, tails included.
///
/// ```dart
/// const Ribbon(size: RibbonSize.lg, child: Text('New arrivals'))
/// Ribbon(
///   variant: RibbonVariant.swallow,
///   tone: RibbonTone.lemon,
///   onPressed: openDetails,
///   child: const Text('See details'),
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/ribbon.tsx`.
class Ribbon extends StatefulWidget {
  const Ribbon({
    super.key,
    required this.child,
    this.variant = RibbonVariant.banner,
    this.tone = RibbonTone.marker,
    this.size = RibbonSize.regular,
    this.onPressed,
    this.leading,
    this.trailing,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The words, usually a [Text].
  final Widget child;

  final RibbonVariant variant;

  /// The paper's color; ink stays readable on each.
  final RibbonTone tone;
  final RibbonSize size;

  /// Makes the ribbon a button, called on tap, Enter and Space.
  final VoidCallback? onPressed;

  /// An icon before the words.
  final Widget? leading;

  /// An icon after the words.
  final Widget? trailing;

  /// Pins the hand: the same seed always draws the same ribbon.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name when the words are not text.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<Ribbon> createState() => _RibbonState();
}

class _RibbonState extends State<Ribbon> with InkSeed {
  bool get _interactive => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final params = RibbonParams(
      variant: widget.variant,
      tone: widget.tone,
      size: widget.size,
      hoverable: _interactive,
    );
    final source = RecipeInkSource(
      ribbonRecipe,
      params,
      json: params.toJson(),
    );
    if (!_interactive) {
      return Semantics(
        container: true,
        label: widget.semanticLabel,
        child: _body(context, source, widget.forcedStates),
      );
    }
    return Semantics(
      container: true,
      button: true,
      label: widget.semanticLabel,
      child: InkInteraction(
        onActivate: widget.onPressed,
        states: widget.forcedStates,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        builder: (context, states) => _body(context, source, states),
      ),
    );
  }

  Widget _body(BuildContext context, InkSource source, Set<InkState> states) {
    final theme = LooseleafTheme.of(context);
    final size = widget.size;
    final variant = widget.variant;
    final inset = ribbonInset(variant, size);
    final drop = ribbonDrop(variant, size);
    final lifted = _interactive && states.contains(InkState.hovered);
    final ribbon = InkContent(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: size.font,
        cssLineHeight: size.cssLineHeight,
        fontWeight: FontWeight.w700,
        color: theme.colors.ink,
      ),
      iconSize: Spacing.d16,
      wrap: false,
      child: InkSurface(
        source: source,
        seed: inkSeed(widget.seed),
        states: states,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 2 * inset + Spacing.d24),
          child: SizedBox(
            height: size.band + drop,
            child: Padding(
              padding: EdgeInsets.only(
                left: inset + ribbonGutter(variant),
                right: inset + ribbonGutter(variant),
                bottom: drop,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: Spacing.d6,
                children: [
                  ?widget.leading,
                  Flexible(child: widget.child),
                  ?widget.trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!_interactive) return ribbon;
    return TweenAnimationBuilder<double>(
      tween: Tween(
        end: switch (lifted) {
          true => -1,
          false => 0,
        },
      ),
      duration: InkMotion.of(context, InkMotion.hover),
      curve: InkMotion.settle,
      builder: (context, lift, child) =>
          Transform.translate(offset: Offset(0, lift), child: child),
      child: ribbon,
    );
  }
}
