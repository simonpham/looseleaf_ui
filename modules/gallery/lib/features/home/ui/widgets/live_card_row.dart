import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One card of a [LiveCardRow]: its share of twelve columns at wide
/// widths, and whether it takes both columns at medium widths.
typedef LiveCard = ({int span, bool fullAtMedium, Widget child});

/// A row of live cards: side by side on a twelve-column grid when wide, two
/// to a row at medium widths, one under the other on phones.
///
/// Mirrors the `grid @2xl:grid-cols-2 @4xl:grid-cols-12` rows of upstream
/// `src/docs/content/home.tsx`.
class LiveCardRow extends StatelessWidget {
  const LiveCardRow({super.key, required this.cards});

  /// From this width the cards sit on twelve columns (upstream `@4xl`).
  static const double twelveColumnsFrom = 896;

  /// From this width the cards sit two to a row (upstream `@2xl`).
  static const double twoColumnsFrom = 672;

  final List<LiveCard> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      if (width >= twelveColumnsFrom) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d40,
          children: [
            for (final card in cards)
              Expanded(flex: card.span, child: card.child),
          ],
        );
      }
      if (width >= twoColumnsFrom) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d56,
          children: [for (final row in _pairs()) _pairRow(row)],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d56,
        children: [for (final card in cards) card.child],
      );
    },
  );

  List<List<LiveCard>> _pairs() {
    final rows = <List<LiveCard>>[];
    var current = <LiveCard>[];
    for (final card in cards) {
      if (card.fullAtMedium) {
        if (current.isNotEmpty) rows.add(current);
        rows.add([card]);
        current = [];
        continue;
      }
      current.add(card);
      if (current.length == 2) {
        rows.add(current);
        current = [];
      }
    }
    if (current.isNotEmpty) rows.add(current);
    return rows;
  }

  Widget _pairRow(List<LiveCard> row) {
    if (row case [final only] when only.fullAtMedium) {
      return Center(child: only.child);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d40,
      children: [
        for (final card in row) Expanded(child: card.child),
        if (row.length == 1) const Spacer(),
      ],
    );
  }
}
