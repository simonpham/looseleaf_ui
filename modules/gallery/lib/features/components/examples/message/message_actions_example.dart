import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = Spacing.d384;

class MessageActionsExample extends StatelessWidget {
  const MessageActionsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d32,
          children: [
            Message(
              children: [
                MessageContent(
                  children: [
                    const Bubble(
                      variant: BubbleVariant.muted,
                      children: [
                        BubbleContent(
                          child: Text(
                            'The install failure is coming from the workspace '
                            'package.',
                          ),
                        ),
                      ],
                    ),
                    MessageFooter(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final (icon, label) in const [
                            ('copy', 'Copy'),
                            ('circle-check', 'Like'),
                            ('circle-x', 'Dislike'),
                          ])
                            Tooltip(
                              content: TooltipContent(child: Text(label)),
                              child: Button(
                                variant: ButtonVariant.ghost,
                                size: ButtonSize.icon,
                                semanticLabel: label,
                                onPressed: () {},
                                child: InkIcon(icon),
                              ),
                            ),
                        ],
                      ),
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
                    const Bubble(
                      children: [
                        BubbleContent(
                          child: Text('Okay drop me a link. Taking a look...'),
                        ),
                      ],
                    ),
                    MessageFooter(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: Spacing.d8,
                        children: [
                          Text(
                            'Failed to send',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: theme.colors.red,
                            ),
                          ),
                          Tooltip(
                            content: const TooltipContent(child: Text('Retry')),
                            child: Button(
                              variant: ButtonVariant.ghost,
                              size: ButtonSize.iconXs,
                              semanticLabel: 'Retry',
                              onPressed: () {},
                              child: const InkIcon('rotate-cw'),
                            ),
                          ),
                        ],
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
}
