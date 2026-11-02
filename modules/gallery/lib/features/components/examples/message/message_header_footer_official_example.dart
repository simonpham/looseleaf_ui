import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = 384.0;

class MessageHeaderFooterOfficialExample extends StatelessWidget {
  const MessageHeaderFooterOfficialExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.d16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d32,
        children: [
          Message(
            children: [
              MessageContent(
                children: [
                  MessageHeader(child: Text('Olivia')),
                  Bubble(
                    variant: BubbleVariant.muted,
                    children: [
                      BubbleContent(child: Text('I already checked the logs.')),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Message(
            align: ChatAlign.end,
            children: [
              MessageContent(
                children: [
                  Bubble(
                    children: [
                      BubbleContent(
                        child: Text(
                          'Send the report to the team. Ping @shadcn if you '
                          'need help.',
                        ),
                      ),
                    ],
                  ),
                  MessageFooter(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Read '),
                          TextSpan(
                            text: 'Yesterday',
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
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
