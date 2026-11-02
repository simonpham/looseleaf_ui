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
          Wrap(
            spacing: Spacing.d16,
            runSpacing: Spacing.d8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Sketches'),
              SizedBox(
                height: Spacing.d24,
                child: Separator(orientation: SeparatorOrientation.vertical),
              ),
              Text('Recipes'),
              SizedBox(
                height: Spacing.d24,
                child: Separator(orientation: SeparatorOrientation.vertical),
              ),
              Text('Receipts'),
              SizedBox(
                height: Spacing.d24,
                child: Separator(orientation: SeparatorOrientation.vertical),
              ),
              Text('Maps'),
            ],
          ),
          Wrap(
            spacing: Spacing.d16,
            runSpacing: Spacing.d8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('12 pages'),
              SizedBox(
                height: Spacing.d24,
                child: Separator(
                  orientation: SeparatorOrientation.vertical,
                  variant: SeparatorVariant.dotted,
                ),
              ),
              Text('3 tabs'),
              SizedBox(
                height: Spacing.d24,
                child: Separator(
                  orientation: SeparatorOrientation.vertical,
                  variant: SeparatorVariant.dotted,
                ),
              ),
              Text('1 coffee ring'),
            ],
          ),
          Wrap(
            spacing: Spacing.d24,
            runSpacing: Spacing.d8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Draft'),
              SizedBox(
                height: Spacing.d40,
                child: Separator(
                  orientation: SeparatorOrientation.vertical,
                  variant: SeparatorVariant.stitched,
                ),
              ),
              Text('Review'),
              SizedBox(
                height: Spacing.d40,
                child: Separator(
                  orientation: SeparatorOrientation.vertical,
                  variant: SeparatorVariant.tape,
                ),
              ),
              Text('Done'),
              SizedBox(
                height: Spacing.d40,
                child: Separator(
                  orientation: SeparatorOrientation.vertical,
                  variant: SeparatorVariant.wavy,
                ),
              ),
              Text('Filed'),
            ],
          ),
        ],
      ),
    );
  }
}
