import 'package:flutter/widgets.dart';
import 'package:gallery/features/home/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Why Looseleaf": four reasons on index cards, two to a row when there
/// is room.
///
/// Mirrors `Why` in upstream `src/docs/content/home/why.tsx`.
class HomeWhy extends StatelessWidget {
  const HomeWhy({super.key, required this.ownCount});

  /// Components Looseleaf adds beyond shadcn/ui.
  final int ownCount;

  static const List<({String title, Accent flag, String text, String foot})>
  _reasons = [
    (
      title: 'Practical',
      flag: Accent.tomato,
      text:
          'Same parts and props as shadcn/ui. Add one package and every widget is there, with nothing to copy and nothing to wire up.',
      foot: 'one package',
    ),
    (
      title: 'Handmade',
      flag: Accent.sky,
      text:
          'Lines have pressure. Fills are solid and sit in their outlines. Paper has tooth. Every stroke is seeded, so every run draws the same hand.',
      foot: 'no two alike',
    ),
    (
      title: 'Accessible',
      flag: Accent.grass,
      text:
          "Flutter's own semantics underneath: keyboard, focus rings, AA text, 24 px targets, reduced motion. The charm is decoration; the semantics are ordinary.",
      foot: 'screen-reader ready',
    ),
    (
      title: 'Themeable',
      flag: Accent.grape,
      text:
          'One set of tokens, three densities. Change a color in LooseleafThemeData and everything follows; switch on calm and a dense dashboard goes quiet.',
      foot: 'tokens + themes',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lead = switch (ownCount) {
      0 => 'Every shadcn component.',
      _ => 'Every shadcn component, plus $ownCount of our own.',
    };
    final cards = [
      for (final (index, reason) in _reasons.indexed)
        WhyCard(
          title: reason.title,
          text: switch (index) {
            0 => '$lead ${reason.text}',
            _ => reason.text,
          },
          foot: reason.foot,
          flag: reason.flag,
          number: index + 1,
          total: _reasons.length,
        ),
    ];
    return DeskSection(
      title: 'Why Looseleaf',
      lede:
          'A design system that is fun to look at is only worth shipping if it is also a good component library. Both, on purpose.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < LiveCardRow.twoColumnsFrom) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d48,
              children: cards,
            );
          }
          return Column(
            spacing: Spacing.d48,
            children: [
              for (var start = 0; start < cards.length; start += 2)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d40,
                  children: [
                    for (final card in cards.skip(start).take(2))
                      Expanded(child: card),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
