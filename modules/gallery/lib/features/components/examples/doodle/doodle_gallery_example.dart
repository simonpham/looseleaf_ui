import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DoodleGalleryExample extends StatelessWidget {
  const DoodleGalleryExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return GridView.extent(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      maxCrossAxisExtent: Spacing.d128 + Spacing.d32,
      mainAxisSpacing: Spacing.d16,
      crossAxisSpacing: Spacing.d16,
      children: [
        for (final name in doodles.keys)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d4,
            children: [
              Doodle(name, size: 72),
              Text(
                name,
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.pencilText,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
