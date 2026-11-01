import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/accordion/accordion_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One row of an [Accordion]: an [AccordionTrigger] and an
/// [AccordionContent] in [child], with a pencil rule under it (except
/// under the last row).
///
/// Mirrors `AccordionItem` in upstream `src/components/ui/accordion.tsx`.
class AccordionItem extends StatelessWidget {
  const AccordionItem({
    super.key,
    required this.value,
    required this.child,
    this.disabled = false,
  });

  /// Identifies the item in the accordion's value.
  final String value;

  final Widget child;
  final bool disabled;

  static final _rule = RecipeInkSource(
    accordionRuleRecipe,
    const NoParams(),
    json: const NoParams().toJson(),
  );

  @override
  Widget build(BuildContext context) {
    final accordion = AccordionScope.maybeOf(context);
    final last = AccordionSlot.maybeOf(context)?.last ?? true;
    return AccordionItemScope(
      value: value,
      open: accordion?.open.contains(value) ?? false,
      disabled: disabled || (accordion?.disabled ?? false),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.d8),
            child: child,
          ),
          if (!last)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: Spacing.d8,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: _Rule(source: _rule, value: value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.source, required this.value});

  final InkSource source;
  final String value;

  @override
  Widget build(BuildContext context) =>
      InkSurface(source: source, seed: 'accordion-rule-$value', still: true);
}
