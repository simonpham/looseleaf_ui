import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One reason on an index card: a flag, a title, the text and a footer
/// numbering it "n of total".
///
/// Mirrors a card of `Why` in upstream `src/docs/content/home/why.tsx`.
class WhyCard extends StatelessWidget {
  const WhyCard({
    super.key,
    required this.title,
    required this.text,
    required this.foot,
    required this.flag,
    required this.number,
    required this.total,
  });

  /// Upstream's `min-h-72`.
  static const double minHeight = 288;

  final String title;
  final String text;
  final String foot;
  final Accent flag;

  /// Its place among the reasons, from 1.
  final int number;
  final int total;

  @override
  Widget build(BuildContext context) => IndexCard(
    seed: 'why-${title.toLowerCase()}',
    flag: flag,
    stack: switch (number.isOdd) {
      true => 1,
      false => 0,
    },
    maxWidth: double.infinity,
    minHeight: minHeight,
    children: [
      IndexCardHeader(children: [IndexCardTitle(Text(title))]),
      IndexCardContent(children: [Text(text)]),
      IndexCardFooter(children: [Text(foot), Text('$number of $total')]),
    ],
  );
}
