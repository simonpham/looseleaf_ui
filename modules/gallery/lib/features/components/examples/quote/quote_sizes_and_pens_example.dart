import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-xs`.
const _ruleMaxWidth = Spacing.d320;

/// Below this width the grid is one column (`sm:grid-cols-2`).
const _twoColumns = 400.0;

class QuoteSizesAndPensExample extends StatelessWidget {
  const QuoteSizesAndPensExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = switch (constraints.maxWidth < _twoColumns) {
          true => constraints.maxWidth,
          false => (constraints.maxWidth - Spacing.d40) / 2,
        };
        return Wrap(
          spacing: Spacing.d40,
          runSpacing: Spacing.d32,
          children: [
            for (final quote in <Widget>[
              Quote(
                children: [
                  QuoteText(
                    size: QuoteSize.sm,
                    child: Text(
                      'Small and quiet.',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const Quote(
                children: [
                  QuoteText(
                    size: QuoteSize.lg,
                    tone: MarkPen.blue,
                    weight: MarkWeight.brush,
                    child: Text('Big and blue.'),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: Spacing.d76),
                    child: QuoteAttribution(child: Text('Sam')),
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _ruleMaxWidth),
                child: const Quote(
                  children: [
                    QuoteText(
                      rule: true,
                      tone: MarkPen.red,
                      child: Text(
                        'A rule down the side, in pencil, so a long quotation '
                        'keeps its edge all the way down.',
                      ),
                    ),
                  ],
                ),
              ),
              const Quote(
                children: [
                  QuoteText(
                    tone: MarkPen.ink,
                    weight: MarkWeight.fine,
                    child: Text('Ink, with a fine hand.'),
                  ),
                ],
              ),
            ])
              SizedBox(width: cellWidth, child: quote),
          ],
        );
      },
    );
  }
}
