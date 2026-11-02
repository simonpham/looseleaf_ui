import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The frame of the shadcn examples: a 560 px card at most 384 px wide
/// with a ruled-off header ([title], [description], an optional [action]),
/// the transcript [body] filling the middle, an optional [footer], and a
/// small [caption] under the card.
class MessageScrollerDemoCard extends StatelessWidget {
  const MessageScrollerDemoCard({
    super.key,
    required this.title,
    required this.description,
    required this.body,
    required this.caption,
    this.action,
    this.footer,
    this.footerDivider = true,
  });

  final String title;
  final String description;
  final Widget body;
  final String caption;
  final Widget? action;
  final Widget? footer;

  /// Rules the footer off from the transcript.
  final bool footerDivider;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final action = this.action;
    final footer = this.footer;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          SizedBox(
            height: 560,
            child: Card(
              gap: 0,
              children: [
                CardHeader(
                  divider: true,
                  children: [
                    CardTitle(Text(title)),
                    CardDescription(Text(description)),
                    if (action != null) CardAction(child: action),
                  ],
                ),
                Expanded(
                  child: CardContent(padding: EdgeInsets.zero, child: body),
                ),
                if (footer != null)
                  CardFooter(
                    divider: footerDivider,
                    children: [Expanded(child: footer)],
                  ),
              ],
            ),
          ),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: theme.typography.interface(
              cssSize: 12,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
