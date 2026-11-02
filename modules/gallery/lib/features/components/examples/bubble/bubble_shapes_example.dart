import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BubbleShapesExample extends StatelessWidget {
  const BubbleShapesExample({super.key});

  static const _maxWidth = 576.0;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(
          Spacing.d16,
          0,
          Spacing.d16,
          Spacing.d32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d32,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d32,
              children: [
                Expanded(
                  child: Bubble(
                    shape: BubbleShape.note,
                    children: [
                      BubbleContent(
                        seed: 'note',
                        minHeight: Spacing.d56,
                        paper: BubblePaper(tiltDegrees: -1.6),
                        child: Text('meet me by the library at four'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Bubble(
                    shape: BubbleShape.sticky,
                    variant: BubbleVariant.secondary,
                    children: [
                      BubbleContent(
                        seed: 'sticky',
                        minHeight: Spacing.d96,
                        padding: EdgeInsets.fromLTRB(
                          Spacing.d16,
                          Spacing.d28,
                          Spacing.d16,
                          Spacing.d10,
                        ),
                        paper: BubblePaper(
                          tiltDegrees: 1.8,
                          fastener: FastenerKind.pin,
                        ),
                        child: Text('buy more ink!'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d32,
              children: [
                Expanded(
                  child: Bubble(
                    shape: BubbleShape.sticky,
                    variant: BubbleVariant.tinted,
                    align: ChatAlign.end,
                    children: [
                      BubbleContent(
                        seed: 'sticky-2',
                        minHeight: Spacing.d96,
                        paper: BubblePaper(tiltDegrees: -1.4),
                        child: Text('call mum before six'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Bubble(
                    variant: BubbleVariant.outline,
                    pen: BubblePen.you,
                    align: ChatAlign.end,
                    children: [
                      BubbleContent(
                        seed: 'you',
                        child: Text('Make the chips a little smaller, please.'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
