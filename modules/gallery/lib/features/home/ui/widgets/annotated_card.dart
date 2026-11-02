import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Reading notes on ruled paper, marked up by hand: a highlighter swipe, a
/// red circle, a callout and a tally.
///
/// Mirrors `Annotated` in upstream `src/docs/content/home/annotated.tsx`.
class AnnotatedCard extends StatelessWidget {
  const AnnotatedCard({super.key});

  static const double _rule = 28;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final body = theme.typography.interface(
      cssSize: 17,
      color: theme.colors.ink,
    );
    final note = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.pencilText,
    );
    return Paper(
      stock: StockName.paper,
      rules: RuleName.ruled,
      tape: PaperTape.corner,
      seed: 'home-notes',
      padding: const EdgeInsetsDirectional.fromSTEB(
        Spacing.d56,
        Spacing.d16,
        Spacing.d24,
        Spacing.d20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _rule,
            child: Text(
              'Reading notes / Tuesday',
              style: theme.typography.stamp(
                cssSize: 14,
                color: theme.colors.pencilText,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _rule * 2),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Same parts, new hand',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 33.6,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
            ),
          ),
          Text.rich(
            TextSpan(
              style: body,
              children: [
                const TextSpan(
                  text:
                      "Looseleaf keeps shadcn's API and swaps the skin. Every line is ",
                ),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Highlight(
                    seed: 'home-notes-pen',
                    child: Text('drawn by a pen with pressure'),
                  ),
                ),
                const TextSpan(text: ', every fill sits '),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Circled(
                    tone: MarkPen.red,
                    animate: true,
                    seed: 'home-notes-clean',
                    child: Text('clean inside it'),
                  ),
                ),
                const TextSpan(text: ', and no two buttons are quite alike.'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.only(end: Spacing.d8),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Callout(
                'on purpose!',
                direction: ArrowDirection.upLeft,
                animate: true,
                delay: Duration(milliseconds: 500),
                seed: 'home-notes-callout',
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _rule),
            child: Row(
              spacing: Spacing.d12,
              children: [
                Flexible(
                  child: Text('times I have said “hand-drawn”', style: note),
                ),
                const Tally(count: 7, animate: true, seed: 'home-notes-tally'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
