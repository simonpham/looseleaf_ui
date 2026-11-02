import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerUnreadExample extends StatefulWidget {
  const MarkerUnreadExample({super.key});

  @override
  State<MarkerUnreadExample> createState() => _MarkerUnreadExampleState();
}

class _MarkerUnreadExampleState extends State<MarkerUnreadExample> {
  static const _maxWidth = 512.0;

  var _read = false;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.d16,
          0,
          Spacing.d16,
          Spacing.d16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d12,
          children: [
            const Bubble(
              variant: BubbleVariant.muted,
              children: [
                BubbleContent(
                  seed: 'un-1',
                  child: Text(
                    'I also drew the chips a little smaller, like you asked.',
                  ),
                ),
              ],
            ),
            switch (_read) {
              true => const Marker(
                variant: MarkerVariant.separator,
                seed: 'read',
                children: [MarkerContent(child: Text('Read'))],
              ),
              false => Marker(
                variant: MarkerVariant.separator,
                tone: MarkerTone.fresh,
                seed: 'new',
                semanticLabel: 'Mark as read: 2 new messages',
                onPressed: () => setState(() => _read = true),
                children: const [
                  MarkerIcon(child: InkIcon('asterisk')),
                  MarkerContent(child: Text('New messages')),
                ],
              ),
            },
            const Bubble(
              variant: BubbleVariant.muted,
              children: [
                BubbleContent(
                  seed: 'un-2',
                  child: Text('One more thing: the count at the top.'),
                ),
              ],
            ),
            const Bubble(
              variant: BubbleVariant.muted,
              children: [
                BubbleContent(
                  seed: 'un-3',
                  child: Text('It says 12 but the list has 11.'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
