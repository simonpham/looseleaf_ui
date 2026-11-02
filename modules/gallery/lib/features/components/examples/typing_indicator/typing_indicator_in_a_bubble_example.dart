import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TypingIndicatorInABubbleExample extends StatefulWidget {
  const TypingIndicatorInABubbleExample({super.key});

  @override
  State<TypingIndicatorInABubbleExample> createState() =>
      _TypingIndicatorInABubbleExampleState();
}

class _TypingIndicatorInABubbleExampleState
    extends State<TypingIndicatorInABubbleExample> {
  bool _typing = true;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.d16,
          0,
          Spacing.d16,
          Spacing.d16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d16,
          children: [
            const Bubble(
              variant: BubbleVariant.muted,
              children: [
                BubbleContent(
                  seed: 'ti-1',
                  child: Text('Let me look at that...'),
                ),
              ],
            ),
            Visibility(
              visible: _typing,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              maintainSemantics: true,
              child: Bubble(
                variant: BubbleVariant.muted,
                children: [
                  BubbleContent(
                    seed: 'ti-2',
                    child: TypingIndicator(
                      active: _typing,
                      label: 'Stubby is typing',
                      seed: 'ti',
                    ),
                  ),
                ],
              ),
            ),
            Button(
              variant: ButtonVariant.ghost,
              size: ButtonSize.sm,
              onPressed: () => setState(() => _typing = !_typing),
              child: Text(switch (_typing) {
                true => 'Stop typing',
                false => 'Start typing',
              }),
            ),
          ],
        ),
      ),
    ),
  );
}
