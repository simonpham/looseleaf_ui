import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/faq_01/faq_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The questions on a taped sheet of ruled paper, the first one open.
///
/// Mirrors upstream `src/blocks/faq-01/components/faq-01-sheet.tsx`.
class Faq01Sheet extends StatelessWidget {
  const Faq01Sheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final line = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 17,
      cssLineHeight: 28 / 17,
    );
    return Paper(
      rules: RuleName.ruled,
      mirrorRules: Directionality.of(context) == TextDirection.rtl,
      tape: PaperTape.corner,
      seed: 'faq-sheet',
      padding: const EdgeInsetsDirectional.only(
        top: Spacing.d16,
        end: Spacing.d20,
        bottom: Spacing.d28,
        start: Spacing.d56,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Frequently asked',
            style: theme.typography.face(
              KevinSansFace.type,
              cssSize: 14,
              cssLineHeight: 28 / 14,
              color: theme.colors.pencilText,
            ),
          ),
          Accordion(
            collapsible: true,
            defaultValue: const {'free'},
            children: [
              for (final item in faq01Questions)
                AccordionItem(
                  value: item.id,
                  showRule: false,
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AccordionTrigger(
                        minHeight: Spacing.d56,
                        padding: const EdgeInsets.only(top: Spacing.d28),
                        crossAxisAlignment: CrossAxisAlignment.end,
                        child: Text(
                          item.question,
                          style: line.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      AccordionContent(
                        padding: EdgeInsets.zero,
                        child: Text(item.answer, style: line),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
