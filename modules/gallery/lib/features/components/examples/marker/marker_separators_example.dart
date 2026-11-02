import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerSeparatorsExample extends StatelessWidget {
  const MarkerSeparatorsExample({super.key});

  static const _maxWidth = Spacing.d512;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(Spacing.d16, 0, Spacing.d16, Spacing.d16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d12,
          children: [
            Marker(
              variant: MarkerVariant.separator,
              seed: 'wed',
              children: [MarkerContent(child: Text('Wednesday'))],
            ),
            Bubble(
              variant: BubbleVariant.muted,
              children: [
                BubbleContent(
                  seed: 'sep-1',
                  child: Text('Did the tags make it into the build?'),
                ),
              ],
            ),
            Bubble(
              align: ChatAlign.end,
              children: [
                BubbleContent(
                  seed: 'sep-2',
                  child: Text('They did. Filter row is next.'),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: Spacing.d12),
              child: Marker(
                variant: MarkerVariant.separator,
                seed: 'today',
                children: [MarkerContent(child: Text('Today'))],
              ),
            ),
            Bubble(
              variant: BubbleVariant.muted,
              children: [
                BubbleContent(
                  seed: 'sep-3',
                  child: Text('Morning! The filter row is in.'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
