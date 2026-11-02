import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class IndexCardTapedAndClippedExample extends StatelessWidget {
  const IndexCardTapedAndClippedExample({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(Spacing.d16),
    child: Wrap(
      spacing: Spacing.d40,
      runSpacing: Spacing.d48,
      children: [
        IndexCard(
          tape: PaperTape.both,
          tapeKind: TapeKind.washiDots,
          stack: 1,
          seed: 'washi',
          minHeight: 194,
          children: [
            IndexCardHeader(children: [IndexCardTitle(Text('Taped up'))]),
            IndexCardContent(children: [Text('two strips of washi')]),
          ],
        ),
        IndexCard(
          fastener: FastenerKind.clip,
          seed: 'clip',
          minHeight: 194,
          children: [
            IndexCardHeader(children: [IndexCardTitle(Text('Clipped'))]),
            IndexCardContent(children: [Text('a paper clip, top right')]),
            IndexCardFooter(children: [Text('page 1 of 1')]),
          ],
        ),
      ],
    ),
  );
}
