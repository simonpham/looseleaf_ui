import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BracketListGroupExample extends StatelessWidget {
  const BracketListGroupExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d8,
      children: [
        Bracket(
          kind: BracketKind.curly,
          side: BracketSide.end,
          tone: MarkPen.blue,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: Spacing.d32),
            child: DefaultTextStyle.merge(
              style: theme.typography.interface(cssSize: 17),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d6,
                children: [Text('Flour'), Text('Butter'), Text('Sugar')],
              ),
            ),
          ),
        ),
        const Callout('the base'),
      ],
    );
  }
}
