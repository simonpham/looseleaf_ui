import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StampButtonDefaultExample extends StatelessWidget {
  const StampButtonDefaultExample({super.key});

  static const _lines = [
    ('To', 'The Paper Club'),
    ('For', 'Twelve notebooks, felt tips'),
    ('Total', r'$ 148.00'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: StampSurface(
        child: Paper(
          stock: StockName.slip,
          tilt: false,
          padding: const EdgeInsets.fromLTRB(
            Spacing.d24,
            Spacing.d24,
            Spacing.d24,
            Spacing.d16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice 2026-031',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 30,
                  color: theme.colors.ink,
                ),
              ),
              const SizedBox(height: Spacing.d12),
              Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                columnWidths: const {1: FlexColumnWidth()},
                children: [
                  for (final (term, value) in _lines)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: Spacing.d24,
                            bottom: Spacing.d4,
                          ),
                          child: Text(
                            term,
                            style: TextStyle(color: theme.colors.pencilText),
                          ),
                        ),
                        Text(
                          value,
                          style: TextStyle(
                            color: theme.colors.ink,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: Spacing.d96),
              const Wrap(
                spacing: Spacing.d16,
                runSpacing: Spacing.d16,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  StampButton(
                    stamp: 'stamp-approved',
                    place: Offset(0.66, 0.5),
                    child: Text('Approve'),
                  ),
                  StampButton(
                    stamp: 'stamp-void',
                    place: Offset(0.5, 0.42),
                    child: Text('Void'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
