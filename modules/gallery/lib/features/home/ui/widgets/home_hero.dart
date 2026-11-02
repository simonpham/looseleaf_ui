import 'package:flutter/widgets.dart';
import 'package:gallery/features/home/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The top of the home desk: the name, the tagline, what it is, the two
/// ways in and the sign-in card beside them (below them on narrow screens).
///
/// Mirrors `Hero` in upstream `src/docs/content/home/hero.tsx`.
class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.componentCount,
    required this.onGetStarted,
    required this.onBrowse,
  });

  /// Widths from which the card sits beside the words (upstream `@4xl`).
  static const double sideBySideFrom = 896;

  static const double _cardColumn = 400;

  final int componentCount;
  final VoidCallback onGetStarted;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final words = HeroWords(
        roomy: constraints.maxWidth >= HeroWords.roomyFrom,
        componentCount: componentCount,
        onGetStarted: onGetStarted,
        onBrowse: onBrowse,
      );
      if (constraints.maxWidth < sideBySideFrom) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d48,
          children: [words, const SignInCard()],
        );
      }
      return Row(
        spacing: Spacing.d56,
        children: [
          Expanded(child: words),
          const SizedBox(
            width: _cardColumn,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: SignInCard(),
            ),
          ),
        ],
      );
    },
  );
}
