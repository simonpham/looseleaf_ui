import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class LabelTagLinkTagsExample extends StatelessWidget {
  const LabelTagLinkTagsExample({super.key});

  static const _tags = [
    (label: 'Sale', twine: Accent.tomato, stock: StockName.kraft),
    (label: 'New', twine: Accent.grass, stock: StockName.stickyYellow),
    (label: 'Gifts', twine: Accent.sky, stock: StockName.paper),
  ];

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Shop sections',
    child: Padding(
      padding: const EdgeInsets.all(Spacing.d24),
      child: Wrap(
        spacing: Spacing.d40,
        runSpacing: Spacing.d56,
        alignment: WrapAlignment.center,
        children: [
          for (final tag in _tags)
            LabelTag(
              stock: tag.stock,
              twine: tag.twine,
              shape: TagShape.round,
              seed: tag.label,
              width: Spacing.d112,
              height: Spacing.d112,
              onPressed: () {},
              children: [
                LabelTagTitle(Text(tag.label, textAlign: TextAlign.center)),
              ],
            ),
        ],
      ),
    ),
  );
}
