import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = 384.0;

class MessageAvatarExample extends StatelessWidget {
  const MessageAvatarExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.d16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d24,
        children: [
          Message(
            children: [
              MessageAvatar(
                child: Avatar(children: [AvatarFallback(child: Text('R'))]),
              ),
              MessageContent(
                children: [
                  Bubble(
                    variant: BubbleVariant.muted,
                    children: [
                      BubbleContent(
                        child: Text(
                          'The build failed during dependency installation.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Message(
            align: ChatAlign.end,
            children: [
              MessageAvatar(
                child: Avatar(children: [AvatarFallback(child: Text('ME'))]),
              ),
              MessageContent(
                children: [
                  Bubble(
                    children: [
                      BubbleContent(
                        child: Text('Can you share the exact error?'),
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
                child: Avatar(children: [AvatarFallback(child: Text('R'))]),
              ),
              MessageContent(
                children: [
                  BubbleGroup(
                    children: [
                      Bubble(
                        variant: BubbleVariant.muted,
                        children: [
                          BubbleContent(
                            child: Text("Here's the error from the logs"),
                          ),
                        ],
                      ),
                      Bubble(
                        variant: BubbleVariant.muted,
                        children: [
                          BubbleContent(
                            child: Text(
                              'Something went wrong with the build. The '
                              'libraries are not installed correctly. Try '
                              'running the build again.',
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
        ],
      ),
    ),
  );
}
