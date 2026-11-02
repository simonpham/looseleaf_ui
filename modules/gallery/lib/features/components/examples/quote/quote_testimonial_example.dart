import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

class QuoteTestimonialExample extends StatelessWidget {
  const QuoteTestimonialExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Paper(
        stock: StockName.indexCard,
        tape: PaperTape.corner,
        seed: 'quote-card',
        padding: const EdgeInsets.all(Spacing.d28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: Spacing.d16,
              child: Text(
                'Kind words',
                style: theme.typography.face(
                  KevinSansFace.type,
                  cssSize: 12,
                  cssLineHeight: 1.33,
                  color: theme.colors.pencilText,
                ),
              ),
            ),
            const Quote(
              children: [
                QuoteText(
                  animate: true,
                  child: Text(
                    'I stopped using three apps the week I found this. It '
                    'just looks like my notebook.',
                  ),
                ),
                QuoteAttribution(child: Text('Mira, ceramicist')),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: Spacing.d6),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Signature(
                  size: SignatureSize.sm,
                  animate: true,
                  delay: Duration(milliseconds: 900),
                  child: Text('Mira Okonkwo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
