import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ScrollAreaHorizontalExample extends StatelessWidget {
  const ScrollAreaHorizontalExample({super.key});

  static const _notes = [
    (StockName.stickyYellow, 'Buy pens'),
    (StockName.stickyGreen, 'Call mum'),
    (StockName.stickyOrange, 'Water the fern'),
    (StockName.stickyPink, 'Sharpen pencils'),
    (StockName.stickyBlue, 'Read chapter 4'),
    (StockName.stickyYellow, 'Post the parcel'),
    (StockName.stickyGreen, 'Tidy the desk'),
    (StockName.stickyOrange, 'Practice lettering'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Spacing.d128 * 4),
        child: ScrollArea(
          orientation: ScrollAreaOrientation.horizontal,
          bleed: true,
          child: Padding(
            padding: const EdgeInsets.only(bottom: Spacing.d12),
            child: Row(
              spacing: Spacing.d16,
              children: [
                for (final (index, (stock, text)) in _notes.indexed)
                  SizedBox(
                    width: Spacing.d128 + Spacing.d16,
                    height: Spacing.d112,
                    child: Paper(
                      seed: 'note-$index',
                      stock: stock,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.d12,
                      ),
                      child: Center(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: theme.typography
                              .face(KevinSansFace.script, cssSize: 24)
                              .copyWith(height: 1.25),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
