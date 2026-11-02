import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _messages = <MessageScrollerTurn>[
  (
    id: 'vis-brief',
    mine: true,
    text: 'Review the incident handoff and tell me what to read first.',
  ),
  (
    id: 'vis-brief-reply',
    mine: false,
    text:
        'Start with the summary and the impact section. The regression '
        'affected the upload queue, but the recovery path completed for '
        'every queued job.',
  ),
  (id: 'vis-impact', mine: true, text: 'What was the customer impact?'),
  (
    id: 'vis-impact-reply',
    mine: false,
    text:
        'Impact was limited to delayed processing.\n\nNo records were '
        'dropped, and the reconciliation worker confirmed each retry batch. '
        'Support saw confusion from two customers, but there were no '
        'checkout or billing errors.',
  ),
  (id: 'vis-actions', mine: true, text: 'What actions are open?'),
  (
    id: 'vis-actions-reply',
    mine: false,
    text:
        'Keep the retry window enabled until the next deploy, then add a '
        'queue-depth alert as the long-term fix.\n\nThe alert should fire '
        'on sustained queue growth, not a single short spike.',
  ),
  (id: 'vis-checklist', mine: true, text: 'Give me the follow-up checklist.'),
  (
    id: 'vis-checklist-reply',
    mine: false,
    text:
        'Compare the queue recovery graph with the deploy timeline so the '
        'handoff shows exactly when processing returned to baseline.\n\n'
        'Add a short owner note beside each follow-up item, so the '
        'retry-window decision, alert tuning and support macro do not drift '
        'into separate conversations.\n\nKeep the retry window enabled '
        'until the next deploy, then add a queue-depth alert as the '
        'long-term fix.',
  ),
];

final _userMessages = _messages.where((message) => message.mine).toList();

class MessageScrollerVisibilityExample extends StatelessWidget {
  const MessageScrollerVisibilityExample({super.key});

  @override
  Widget build(BuildContext context) => MessageScrollerProvider(
    scrollMargin: Spacing.d12,
    child: MessageScrollerDemoCard(
      title: 'Transcript Outline',
      description: 'Track the current anchored turn.',
      action: const _TranscriptOutline(),
      caption: 'Open the outline to jump between anchored turns as you read.',
      body: MessageScroller(
        children: [
          MessageScrollerViewport(
            child: MessageScrollerContent(
              children: [
                for (final message in _messages)
                  MessageScrollerItem(
                    messageId: message.id,
                    scrollAnchor: message.mine,
                    child: MessageScrollerTurnMessage(turn: message),
                  ),
              ],
            ),
          ),
          const MessageScrollerButton(),
        ],
      ),
    ),
  );
}

class _TranscriptOutline extends StatefulWidget {
  const _TranscriptOutline();

  @override
  State<_TranscriptOutline> createState() => _TranscriptOutlineState();
}

class _TranscriptOutlineState extends State<_TranscriptOutline> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final scroller = MessageScrollerProvider.of(context);
    return ValueListenableBuilder(
      valueListenable: scroller.visibility,
      builder: (context, visibility, _) => Popover(
        open: _open,
        onOpenChange: (open) => setState(() => _open = open),
        content: PopoverContent(
          side: OverlaySide.left,
          width: Spacing.d256,
          padding: const EdgeInsets.all(Spacing.d4),
          semanticLabel: 'Transcript outline',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d4,
            children: [
              for (final message in _userMessages)
                _OutlineRow(
                  text: messageScrollerShortLine(message.text),
                  current: visibility.currentAnchorId == message.id,
                  onPressed: () {
                    scroller.scrollToMessage(message.id, animate: true);
                    setState(() => _open = false);
                  },
                ),
            ],
          ),
        ),
        child: PopoverTrigger(
          child: Semantics(
            label: 'Open transcript outline',
            child: _Ticks(current: visibility.currentAnchorId),
          ),
        ),
      ),
    );
  }
}

class _Ticks extends StatelessWidget {
  const _Ticks({required this.current});

  final String? current;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return SizedBox.square(
      dimension: Spacing.d36,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: Spacing.d4,
        children: [
          for (final (i, message) in _userMessages.indexed)
            Transform.rotate(
              angle: ((i * 7) % 5 - 2) * math.pi / 180,
              child: switch (message.id == current) {
                true => SizedBox(
                  width: Spacing.d20,
                  height: Spacing.d3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.ink,
                      borderRadius: BorderRadius.circular(Spacing.d2),
                    ),
                  ),
                ),
                false => SizedBox(
                  width: Spacing.d14,
                  height: Spacing.d2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.pencil.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(Spacing.d2),
                    ),
                  ),
                ),
              },
            ),
        ],
      ),
    );
  }
}

class _OutlineRow extends StatelessWidget {
  const _OutlineRow({
    required this.text,
    required this.current,
    required this.onPressed,
  });

  final String text;
  final bool current;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      button: true,
      selected: current,
      child: InkInteraction(
        onActivate: onPressed,
        builder: (context, states) => SidebarSwipe(
          on:
              current ||
              states.contains(InkState.hovered) ||
              states.contains(InkState.focused),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Spacing.d28),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.d8,
                vertical: Spacing.d6,
              ),
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography
                    .interface(cssSize: 14)
                    .copyWith(
                      fontWeight: switch (current) {
                        true => FontWeight.w700,
                        false => FontWeight.w400,
                      },
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
