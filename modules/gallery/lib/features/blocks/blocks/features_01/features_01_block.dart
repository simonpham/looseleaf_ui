import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/features_01/features_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A features section: a kicker, a lettered title and a lead over three
/// features, as index cards ([Features01Variant.cards]) or pinned to a
/// corkboard ([Features01Variant.bento]).
///
/// Mirrors upstream `src/blocks/features-01/page.tsx`.
class Features01Block extends StatelessWidget {
  const Features01Block({
    super.key,
    this.variant = Features01Variant.cards,
    this.title = 'Everything a good notebook does',
    this.lead = 'Three things we sweated over, and a few we quietly love.',
  });

  /// How the features are laid out.
  final Features01Variant variant;

  /// The lettered title.
  final String title;

  /// The line under the title.
  final String lead;

  static const double _maxWidth = 1152;
  static const double _headerWidth = 672;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final roomy = width >= 576;
        return Padding(
          padding: switch (roomy) {
            true => const EdgeInsets.symmetric(
              horizontal: Spacing.d32,
              vertical: Spacing.d80,
            ),
            false => const EdgeInsets.symmetric(
              horizontal: Spacing.d16,
              vertical: Spacing.d56,
            ),
          },
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
                        children: [
                          Text(
                            'What’s inside',
                            textAlign: TextAlign.center,
                            style: theme.typography.face(
                              KevinSansFace.type,
                              cssSize: 14,
                              cssLineHeight: 20 / 14,
                              color: theme.colors.inkSoft,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: Spacing.d12),
                            child: Lettering(
                              title,
                              tone: LetteringTone.sky,
                              wobble: 0.4,
                              seed: 'features-${variant.name}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: Spacing.d16),
                            child: Text(
                              lead,
                              textAlign: TextAlign.center,
                              style: theme.typography.face(
                                KevinSansFace.hand,
                                cssSize: 20,
                                cssLineHeight: 32 / 20,
                                color: theme.colors.inkSoft,
                              ),
                            ),
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
                    child: switch (variant) {
                      Features01Variant.cards => Features01Cards(width: width),
                      Features01Variant.bento => Features01Bento(width: width),
                    },
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
