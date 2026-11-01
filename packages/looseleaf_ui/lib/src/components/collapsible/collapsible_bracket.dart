import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// [child] with a hand-drawn margin bracket down its start edge, drawn on
/// when [animate] (once the user has opened the panel): the bracket of
/// [CollapsibleContent] and [AccordionContent].
///
/// Mirrors the `Bracket` parts of upstream `collapsible.tsx` and
/// `accordion.tsx` (`marginBracketRecipe`, `MARGIN_BRACKET_DRAW`).
class CollapsibleBracket extends StatefulWidget {
  const CollapsibleBracket({
    super.key,
    required this.kind,
    required this.child,
    this.animate = false,
  });

  final BracketKind kind;
  final bool animate;
  final Widget child;

  @override
  State<CollapsibleBracket> createState() => _CollapsibleBracketState();
}

class _CollapsibleBracketState extends State<CollapsibleBracket> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final params = MarginBracketParams(kind: widget.kind);
    return Stack(
      children: [
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: Spacing.d14,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: InkMarkSurface(
                source: RecipeInkSource(
                  marginBracketRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: inkSeed(null),
                animate: widget.animate,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: Spacing.d20),
          child: widget.child,
        ),
      ],
    );
  }
}
