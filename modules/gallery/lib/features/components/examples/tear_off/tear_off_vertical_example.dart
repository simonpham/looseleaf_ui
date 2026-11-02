import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TearOffVerticalExample extends StatelessWidget {
  const TearOffVerticalExample({super.key});

  static const _width = 224.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final title = theme.typography.face(
      KevinSansFace.script,
      cssSize: 30,
      cssLineHeight: 1,
    );
    return TearOff(
      orientation: Axis.vertical,
      tornMessage: 'One free coffee, redeemed.',
      children: [
        TearOffBody(
          stock: StockName.kraft,
          width: _width,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d20,
            vertical: Spacing.d16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d8,
            children: [
              Text('Coffee card', style: title),
              Text(
                'nine stamped, one free',
                style: theme.typography.interface(cssSize: 14),
              ),
            ],
          ),
        ),
        TearOffStub(
          stock: StockName.stickyYellow,
          width: _width,
          height: Spacing.d80,
          children: [Text('free coffee', style: title)],
        ),
      ],
    );
  }
}
