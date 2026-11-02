import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PaperReceiptExample extends StatelessWidget {
  const PaperReceiptExample({super.key});

  static const _rows = [
    ('oat latte', '4.50'),
    ('washi x3', '9.00'),
    ('glue stick', '2.10'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final type = theme.typography.face(KevinSansFace.type, cssSize: 14);
    final big = theme.typography.face(KevinSansFace.type, cssSize: 16);
    const numbers = [FontFeature.tabularFigures()];
    return Center(
      child: SizedBox(
        width: Spacing.d256,
        child: Paper(
          stock: StockName.receipt,
          seed: 'till',
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d20,
            vertical: Spacing.d28,
          ),
          child: DefaultTextStyle.merge(
            style: type,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Looseleaf Cafe',
                  textAlign: TextAlign.center,
                  style: big.copyWith(letterSpacing: 1.6),
                ),
                const SizedBox(height: Spacing.d12),
                _Dashed(color: theme.colors.pencilMark),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
                  child: Column(
                    children: [
                      for (final (item, price) in _rows)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item),
                            Text(
                              price,
                              style: const TextStyle(fontFeatures: numbers),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                _Dashed(color: theme.colors.pencilMark),
                const SizedBox(height: Spacing.d8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL', style: big),
                    Text(
                      '15.60',
                      style: big.copyWith(
                        color: theme.colors.red,
                        fontFeatures: numbers,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.d12),
                Text(
                  'thank you - come again',
                  textAlign: TextAlign.center,
                  style: theme.typography.face(
                    KevinSansFace.type,
                    cssSize: 12,
                    color: theme.colors.inkMuted,
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

class _Dashed extends StatelessWidget {
  const _Dashed({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final dashes = (constraints.maxWidth / Spacing.d6).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < dashes; i++)
            SizedBox(
              width: Spacing.d3,
              height: Spacing.d1,
              child: ColoredBox(color: color),
            ),
        ],
      );
    },
  );
}
