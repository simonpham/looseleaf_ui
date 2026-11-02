import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/landing_hero_01/landing_hero_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A landing hero on a taped sheet: the header, "Write it down." with
/// marks that draw themselves on, two buttons, a row of happy customers,
/// and a collage of paper beside it (under it on narrower pages).
///
/// Mirrors upstream `src/blocks/landing-hero-01/page.tsx`.
class LandingHero01Block extends StatelessWidget {
  const LandingHero01Block({super.key});

  static const double _maxWidth = 1152;
  static const double _leadWidth = 576;
  static const _people = [
    'Ada Lovelace',
    'Jo Okafor',
    'Mika Kobayashi',
    'Sam Reyes',
  ];

  static WidgetSpan _inline(Widget child) => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final arrow = InkIcon(
      'arrow-right',
      flip: switch (Directionality.of(context)) {
        TextDirection.rtl => IconFlip.x,
        TextDirection.ltr => IconFlip.none,
      },
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final roomy = width >= 576;
        final wide = width >= 1024;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notes and tasks for small teams',
              style: theme.typography.face(
                KevinSansFace.type,
                cssSize: 14,
                cssLineHeight: 20 / 14,
                color: theme.colors.pencilText,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: Spacing.d12),
              child: Lettering(
                'Write it down.',
                size: LetteringSize.xl,
                wobble: 0.5,
                seed: 'hero-title',
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Spacing.d20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _leadWidth),
                child: DefaultTextStyle.merge(
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: switch (roomy) {
                      true => 22,
                      false => 20,
                    },
                    cssLineHeight: switch (roomy) {
                      true => 36 / 22,
                      false => 32 / 20,
                    },
                    color: theme.colors.inkSoft,
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Penmark keeps your team’s notes, tasks and half-formed ideas on ',
                        ),
                        _inline(
                          const Annotate(
                            type: AnnotateType.underline,
                            kind: UnderlineMarkKind.wavy,
                            color: AnnotateColor.blue,
                            animate: true,
                            delay: Duration(milliseconds: 600),
                            seed: 'hero-underline',
                            child: Text('one calm page'),
                          ),
                        ),
                        const TextSpan(text: ', so the good stuff gets '),
                        _inline(
                          const Annotate(
                            type: AnnotateType.highlight,
                            color: AnnotateColor.yellow,
                            animate: true,
                            delay: Duration(milliseconds: 1100),
                            seed: 'hero-highlight',
                            child: Text('found'),
                          ),
                        ),
                        const TextSpan(text: ', not lost.'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Spacing.d32),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Spacing.d16,
                runSpacing: Spacing.d12,
                children: [
                  Button(
                    size: ButtonSize.lg,
                    onPressed: () {},
                    trailing: arrow,
                    child: const Text('Start a notebook'),
                  ),
                  Button(
                    size: ButtonSize.lg,
                    variant: ButtonVariant.outline,
                    onPressed: () {},
                    leading: const InkIcon('circle-play'),
                    child: const Text('Watch the tour'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Spacing.d16),
              child: DefaultTextStyle.merge(
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 15,
                  color: theme.colors.inkMuted,
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      _inline(
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: Spacing.d4),
                          child: Annotate(
                            type: AnnotateType.circle,
                            color: AnnotateColor.red,
                            animate: true,
                            delay: Duration(milliseconds: 1600),
                            seed: 'hero-free',
                            child: Text('Free'),
                          ),
                        ),
                      ),
                      const TextSpan(
                        text: ' for teams of five. No card, no catch.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Spacing.d40),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Spacing.d20,
                runSpacing: Spacing.d12,
                children: [
                  AvatarGroup(
                    children: [
                      for (final name in _people)
                        Avatar(children: [AvatarFallback(name: name)]),
                      const AvatarGroupCount(child: Text('+4k')),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Rating(
                        readOnly: true,
                        value: 4.5,
                        allowHalf: true,
                        size: RatingSize.sm,
                        semanticLabel: 'Rated 4.5 out of 5 by our customers',
                      ),
                      Text(
                        'Loved by 4,200 small teams',
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 14,
                          cssLineHeight: 20 / 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
        final collage = Center(
          child: LandingHero01Collage(scattered: roomy),
        );
        return Padding(
          padding: const EdgeInsets.all(Spacing.d32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Semantics(
                container: true,
                child: Paper(
                  tilt: false,
                  tape: PaperTape.both,
                  tapeKind: TapeKind.washiDots,
                  seed: 'landing-hero-01',
                  padding: switch (roomy) {
                    true => const EdgeInsets.fromLTRB(
                      Spacing.d40,
                      0,
                      Spacing.d40,
                      Spacing.d64,
                    ),
                    false => const EdgeInsets.fromLTRB(
                      Spacing.d20,
                      0,
                      Spacing.d20,
                      Spacing.d56,
                    ),
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LandingHero01Nav(
                        width: width,
                        innerWidth:
                            math.min(width, _maxWidth) -
                            Spacing.d32 * 2 -
                            switch (roomy) {
                              true => Spacing.d40 * 2,
                              false => Spacing.d20 * 2,
                            },
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: switch (wide) {
                            true => Spacing.d56,
                            false => Spacing.d40,
                          },
                        ),
                        child: switch (wide) {
                          true => Row(
                            spacing: Spacing.d48,
                            children: [
                              Expanded(child: copy),
                              SizedBox(
                                width: LandingHero01Collage.boardWidth,
                                child: collage,
                              ),
                            ],
                          ),
                          false => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: Spacing.d48,
                            children: [copy, collage],
                          ),
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
