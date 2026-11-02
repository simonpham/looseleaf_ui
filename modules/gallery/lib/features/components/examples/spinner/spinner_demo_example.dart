import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerDemoExample extends StatelessWidget {
  const SpinnerDemoExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d320),
      child: InkItem(
        variant: ItemVariant.muted,
        children: [
          const ItemMedia(child: Spinner()),
          const ItemContent(
            children: [
              ItemTitle(
                Text(
                  'Processing payment...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          ItemContent(
            children: [
              Text(
                r'$100.00',
                style: theme.typography
                    .interface(cssSize: 14)
                    .copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
