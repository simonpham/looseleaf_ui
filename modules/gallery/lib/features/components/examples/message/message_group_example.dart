import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = Spacing.d384;

class MessageGroupExample extends StatelessWidget {
  const MessageGroupExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.d16),
      child: MessageGroup(
        children: [
          Message(
            children: [
              MessageAvatar(child: SizedBox.square(dimension: Spacing.d32)),
              MessageContent(
                children: [
                  Bubble(
                    variant: BubbleVariant.muted,
                    children: [
                      BubbleContent(
                        child: Text('I checked the registry addresses.'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Message(
            children: [
              MessageAvatar(
                child: Avatar(children: [AvatarFallback(child: Text('CN'))]),
              ),
              MessageContent(
                children: [
                  Bubble(
                    variant: BubbleVariant.muted,
                    children: [
                      BubbleContent(
                        child: Text(
                          'The component and example JSON now live under the '
                          'UI registry.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
