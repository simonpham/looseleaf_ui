import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/landing_hero_01/landing_hero_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The hero's header: the penmark word mark, the main links (from 672 px
/// wide), "Sign in" (from 448 px) and "Get started".
///
/// Mirrors upstream
/// `src/blocks/landing-hero-01/components/landing-hero-01-nav.tsx`.
class LandingHero01Nav extends StatelessWidget {
  const LandingHero01Nav({
    super.key,
    required this.width,
    required this.innerWidth,
  });

  /// The block's width, for the container breakpoints.
  final double width;

  /// The width the header itself gets.
  final double innerWidth;

  /// What the word mark, the links and the buttons need side by side; the
  /// links stay hidden below it so nothing is squeezed.
  static const double _roomForLinks = 800;

  static const _links = ['Product', 'Pricing', 'Notes', 'Changelog'];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: Spacing.d16,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d8,
              children: [
                const Mascot(size: 32),
                Flexible(
                  child: Text(
                    'penmark',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 30,
                      cssLineHeight: 1,
                      fontWeight: FontWeight.w700,
                      color: theme.colors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (width >= 672 && innerWidth >= _roomForLinks)
            Semantics(
              container: true,
              label: 'Main',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d12,
                children: [
                  for (final link in _links) LandingHero01NavLink(link),
                ],
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d12,
            children: [
              if (width >= 448)
                Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Sign in'),
                ),
              Button(
                size: ButtonSize.sm,
                onPressed: () {},
                child: const Text('Get started'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
