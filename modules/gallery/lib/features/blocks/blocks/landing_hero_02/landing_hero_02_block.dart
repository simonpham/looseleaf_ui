import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/landing_hero_02/landing_hero_02.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A centred hero: a "Version 2 is here" ribbon, a two-tone lettered
/// headline, two buttons, and a working page of today's tasks below.
///
/// Mirrors upstream `src/blocks/landing-hero-02/page.tsx`.
class LandingHero02Block extends StatelessWidget {
  const LandingHero02Block({super.key});

  static const double _maxWidth = 768;
  static const double _leadWidth = 672;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final roomy = constraints.maxWidth >= 576;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            Spacing.d32,
            switch (roomy) {
              true => Spacing.d56,
              false => Spacing.d40,
            },
            Spacing.d32,
            Spacing.d64,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Ribbon(
                        tone: RibbonTone.tangerine,
                        seed: 'hero-2-ribbon',
                        child: Text('Version 2 is here'),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: Spacing.d24),
                        child: Lettering(
                          'Your whole week, on one page.',
                          size: LetteringSize.xl,
                          tone: LetteringTone.teal,
                          duotone: LetteringTone.bubblegum,
                          wobble: 0.4,
                          seed: 'hero-2-title',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.d24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _leadWidth,
                          ),
                          child: Text(
                            'Tasks, notes and the odd doodle, kept together where the whole team can see them. Nothing to configure, and it’s a pleasure to tick things off.',
                            textAlign: TextAlign.center,
                            style: switch (roomy) {
                              true => theme.typography.face(
                                KevinSansFace.hand,
                                cssSize: 22,
                                cssLineHeight: 36 / 22,
                                color: theme.colors.inkSoft,
                              ),
                              false => theme.typography.face(
                                KevinSansFace.hand,
                                cssSize: 20,
                                cssLineHeight: 32 / 20,
                                color: theme.colors.inkSoft,
                              ),
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.d32),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: Spacing.d16,
                          runSpacing: Spacing.d12,
                          children: [
                            Button(
                              size: ButtonSize.lg,
                              onPressed: () {},
                              trailing: InkIcon(
                                'arrow-right',
                                flip: switch (Directionality.of(context)) {
                                  TextDirection.rtl => IconFlip.x,
                                  TextDirection.ltr => IconFlip.none,
                                },
                              ),
                              child: const Text('Try it free'),
                            ),
                            Button(
                              size: ButtonSize.lg,
                              variant: ButtonVariant.secondary,
                              onPressed: () {},
                              child: const Text('Book a demo'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.d16),
                        child: Text(
                          '14 days of everything. Then free for small teams, for good.',
                          textAlign: TextAlign.center,
                          style: theme.typography.face(
                            KevinSansFace.hand,
                            cssSize: 15,
                            color: theme.colors.inkMuted,
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
                    true => Spacing.d128,
                    false => Spacing.d112,
                  },
                ),
                child: const LandingHero02Window(),
              ),
            ],
          ),
        );
      },
    );
  }
}
