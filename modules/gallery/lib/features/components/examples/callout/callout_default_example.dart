import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CalloutDefaultExample extends StatelessWidget {
  const CalloutDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d4,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colors.pencilMark),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.d12,
              vertical: Spacing.d8,
            ),
            child: Text(
              'the total',
              style: theme.typography.interface(cssSize: 17),
            ),
          ),
        ),
        const Callout('check the date!'),
      ],
    );
  }
}
