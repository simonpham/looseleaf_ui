import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SeparatorVerticalExample extends StatelessWidget {
  const SeparatorVerticalExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.interface(cssSize: 15),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d32,
        children: [
          SizedBox(
            height: Spacing.d24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d16,
              children: [
                Text('Sketches'),
                Separator(orientation: SeparatorOrientation.vertical),
                Text('Recipes'),
                Separator(orientation: SeparatorOrientation.vertical),
                Text('Receipts'),
                Separator(orientation: SeparatorOrientation.vertical),
                Text('Maps'),
              ],
            ),
          ),
          SizedBox(
            height: Spacing.d24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d16,
              children: [
                Text('12 pages'),
                Separator(
                  orientation: SeparatorOrientation.vertical,
                  variant: SeparatorVariant.dotted,
                ),
                Text('3 tabs'),
                Separator(
                  orientation: SeparatorOrientation.vertical,
                  variant: SeparatorVariant.dotted,
                ),
                Text('1 coffee ring'),
              ],
            ),
          ),
          SizedBox(
            height: Spacing.d40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d24,
              children: [
                Text('Draft'),
                Separator(
                  orientation: SeparatorOrientation.vertical,
                  variant: SeparatorVariant.stitched,
                ),
                Text('Review'),
                Separator(
                  orientation: SeparatorOrientation.vertical,
                  variant: SeparatorVariant.tape,
                ),
                Text('Done'),
                Separator(
                  orientation: SeparatorOrientation.vertical,
                  variant: SeparatorVariant.wavy,
                ),
                Text('Filed'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
