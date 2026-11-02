import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/testimonials_01/testimonials_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Testimonials pinned to the desk: a lettered title over a five-star
/// rating, a wall of quotes on different papers and a link to the rest.
///
/// Mirrors upstream `src/blocks/testimonials-01/page.tsx`.
class Testimonials01Block extends StatelessWidget {
  const Testimonials01Block({super.key});

  static const double _maxWidth = 1152;
  static const double _headerWidth = 672;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final roomy = constraints.maxWidth >= 576;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.d32,
            vertical: switch (roomy) {
              true => Spacing.d80,
              false => Spacing.d56,
            },
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _headerWidth,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: Spacing.d20,
                        children: [
                          const Lettering(
                            'Kind words, pinned up',
                            tone: LetteringTone.tangerine,
                            wobble: 0.4,
                            seed: 'testimonials-title',
                            textAlign: TextAlign.center,
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: Spacing.d12,
                            runSpacing: Spacing.d4,
                            children: [
                              const Rating(
                                readOnly: true,
                                value: 5,
                                semanticLabel: 'Rated 4.9 out of 5',
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '4.9',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colors.ink,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' average from 2,300 reviews',
                                    ),
                                  ],
                                ),
                                style: theme.typography.face(
                                  KevinSansFace.hand,
                                  cssSize: 18,
                                  cssLineHeight: 28 / 18,
                                  color: theme.colors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: switch (roomy) {
                        true => Spacing.d64,
                        false => Spacing.d56,
                      },
                    ),
                    child: const Testimonials01Wall(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.d56),
                    child: Center(
                      child: Button(
                        variant: ButtonVariant.outline,
                        onPressed: () {},
                        trailing: InkIcon(
                          'arrow-right',
                          flip: switch (Directionality.of(context)) {
                            TextDirection.rtl => IconFlip.x,
                            TextDirection.ltr => IconFlip.none,
                          },
                        ),
                        child: const Text('Read all the reviews'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
