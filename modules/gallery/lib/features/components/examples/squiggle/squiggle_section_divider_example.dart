import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SquiggleSectionDividerExample extends StatelessWidget {
  const SquiggleSectionDividerExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d96 * 4),
      child: Card(
        children: [
          CardHeader(
            children: [
              CardTitle(
                Text(
                  'Weekend',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 24,
                  ),
                ),
              ),
              const CardDescription(Text('Two plans and a maybe')),
            ],
          ),
          CardContent(
            child: DefaultTextStyle.merge(
              style: theme.typography.interface(cssSize: 17),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d12,
                children: [
                  Text('Saturday: the market, then the long way home.'),
                  Squiggle(
                    kind: SquiggleKind.scallops,
                    tone: MarkPen.blue,
                    decorative: false,
                    animate: true,
                  ),
                  Text('Sunday: nothing, carefully.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
