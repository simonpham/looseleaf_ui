import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ArrowDefaultExample extends StatelessWidget {
  const ArrowDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d12,
      children: [
        Text('Next', style: theme.typography.interface(cssSize: 17)),
        const Arrow(),
      ],
    );
  }
}
