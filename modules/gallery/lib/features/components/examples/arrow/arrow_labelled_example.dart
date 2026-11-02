import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ArrowLabelledExample extends StatelessWidget {
  const ArrowLabelledExample({super.key});

  static const _maxWidth = Spacing.d384;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: Spacing.d128),
            child: Card(
              children: [
                CardHeader(
                  children: [
                    CardTitle(
                      Text(
                        'Guest book',
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: 24,
                        ),
                      ),
                    ),
                    const CardDescription(Text('Sign on the line')),
                  ],
                ),
                const CardContent(
                  child: SizedBox(
                    height: Spacing.d40,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Separator(variant: SeparatorVariant.dashed),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const PositionedDirectional(
            end: Spacing.d80,
            bottom: Spacing.d32,
            child: SizedBox(
              width: Spacing.d96,
              height: Spacing.d80,
              child: Arrow(
                direction: ArrowDirection.downLeft,
                curve: ArrowCurve.curved,
                tone: MarkPen.blue,
                label: Text('your name'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
