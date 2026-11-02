import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerColorExample extends StatelessWidget {
  const SpinnerColorExample({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d24,
      children: [
        for (final (color, name) in [
          (colors.red, 'red'),
          (colors.green, 'green'),
          (colors.inkYou, 'blue'),
          (colors.orangeText, 'orange'),
          (colors.grape, 'purple'),
        ])
          DefaultTextStyle.merge(
            style: TextStyle(color: color),
            child: Spinner(size: Spacing.d24, semanticLabel: 'Loading, $name'),
          ),
      ],
    );
  }
}
