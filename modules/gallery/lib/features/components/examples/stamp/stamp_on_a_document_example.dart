import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _lines = [
  (term: 'To', value: 'The Paper Club'),
  (term: 'For', value: 'Twelve notebooks, felt tips'),
  (term: 'Total', value: r'$ 148.00'),
];

class StampOnADocumentExample extends StatelessWidget {
  const StampOnADocumentExample({super.key});

  static const _maxWidth = 448.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final ink = theme.typography.interface(color: theme.colors.ink);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Paper(
        stock: StockName.slip,
        tilt: false,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.d24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d12,
                children: [
                  Text(
                    'Invoice 2026-031',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 30,
                      color: theme.colors.ink,
                    ),
                  ),
                  Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      for (final line in _lines)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: Spacing.d24,
                                bottom: Spacing.d4,
                              ),
                              child: Text(
                                line.term,
                                style: ink.copyWith(
                                  color: theme.colors.pencilText,
                                ),
                              ),
                            ),
                            Text(
                              line.value,
                              style: ink.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const PositionedDirectional(
              end: Spacing.d16,
              bottom: Spacing.d12,
              child: Stamp(name: 'stamp-paid'),
            ),
          ],
        ),
      ),
    );
  }
}
