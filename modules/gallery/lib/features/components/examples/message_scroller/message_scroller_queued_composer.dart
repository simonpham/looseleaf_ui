import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The read-only composer of the scripted examples: the next queued line
/// (or [emptyText] when the script is done), [tools] on the bottom row and
/// a send button at its end.
class MessageScrollerQueuedComposer extends StatelessWidget {
  const MessageScrollerQueuedComposer({
    super.key,
    required this.queued,
    required this.emptyText,
    required this.onSend,
    this.tools,
    this.busy = false,
  });

  final String? queued;
  final String emptyText;
  final VoidCallback onSend;
  final Widget? tools;

  /// Dims the queued line while a reply streams; the send does nothing.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final queued = this.queued;
    final tools = this.tools;
    return InputGroup(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Spacing.d56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.d12,
              vertical: Spacing.d10,
            ),
            child: switch (queued) {
              final text? => Opacity(
                opacity: switch (busy) {
                  true => 0.6,
                  false => 1,
                },
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.ink,
                  ),
                ),
              ),
              null => Text(
                emptyText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.inkMuted,
                ),
              ),
            },
          ),
        ),
        InputGroupAddon(
          align: InputGroupAlign.blockEnd,
          child: Row(
            children: [
              ?tools,
              const Spacer(),
              InputGroupButton(
                variant: ButtonVariant.primary,
                size: InputGroupButtonSize.iconSm,
                semanticLabel: 'Send',
                disabled: queued == null,
                onPressed: switch (busy) {
                  true => () {},
                  false => onSend,
                },
                child: const InkIcon('arrow-up'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
