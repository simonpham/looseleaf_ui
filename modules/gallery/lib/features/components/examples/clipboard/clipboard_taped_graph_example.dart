import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ClipboardTapedGraphExample extends StatelessWidget {
  const ClipboardTapedGraphExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return InkClipboard(
      tone: Accent.sky,
      seed: 'graph',
      tiltDegrees: 0.8,
      maxWidth: Spacing.d96 * 4,
      children: [
        ClipboardPaper(
          stock: StockName.graph,
          rules: RuleName.graph,
          tape: PaperTape.corner,
          seed: 'graph-p',
          padding: const EdgeInsetsDirectional.fromSTEB(
            Spacing.d20,
            Spacing.d36 * 2,
            Spacing.d20,
            Spacing.d20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d8,
            children: [
              Text(
                'Rain, week 39',
                style: theme.typography
                    .face(KevinSansFace.script, cssSize: 28)
                    .copyWith(fontWeight: FontWeight.bold, height: 1),
              ),
              Text(
                'so much of it',
                style: TextStyle(color: theme.colors.inkYou),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
