import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ScrollAreaDemoExample extends StatelessWidget {
  const ScrollAreaDemoExample({super.key});

  static final _tags = [for (var i = 50; i > 0; i--) 'v1.2.0-beta.$i'];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final small = theme.typography.interface(cssSize: 14);
    return SizedBox(
      width: Spacing.d192,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Separator(variant: SeparatorVariant.dashed, seed: 'top'),
          SizedBox(
            height: Spacing.d288,
            child: ScrollArea(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.d16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.d16),
                      child: Text(
                        'Tags',
                        style: small.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    ),
                    for (final tag in _tags) ...[
                      Text(tag, style: small),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.d8,
                        ),
                        child: Separator(seed: tag),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const Separator(variant: SeparatorVariant.dashed, seed: 'bottom'),
        ],
      ),
    );
  }
}
