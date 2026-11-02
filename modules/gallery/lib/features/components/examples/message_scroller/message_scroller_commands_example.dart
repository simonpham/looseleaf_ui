import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _messages = <MessageScrollerTurn>[
  (
    id: 'command-activation',
    mine: true,
    text:
        "We're seeing activation dip after workspace creation. Can you help "
        'me find the likely step?',
  ),
  (
    id: 'command-activation-reply',
    mine: false,
    text:
        'The sharpest drop is between creating the workspace and inviting '
        'the first teammate.\n\nWorkspace creation is still healthy, but the '
        'invite step is where users pause. That suggests the product is '
        'asking for collaboration before the user has enough confidence in '
        'the workspace.',
  ),
  (
    id: 'command-compare',
    mine: true,
    text: 'What should I compare before we change the onboarding flow?',
  ),
  (
    id: 'command-compare-reply',
    mine: false,
    text:
        'Compare three cohorts:\n\n1. Users who choose a template before '
        'inviting teammates.\n2. Users who start from a blank workspace.\n3. '
        'Users who skip invites and return within 24 hours.\n\nIf template '
        'users invite faster, the fix is probably better first-run guidance '
        'rather than a louder invite prompt.',
  ),
  (
    id: 'command-experiment',
    mine: true,
    text: 'Can you turn that into an experiment?',
  ),
  (
    id: 'command-experiment-reply',
    mine: false,
    text:
        'Yes. Create a variant that shows a short checklist after workspace '
        'creation:\n\n- Pick a template.\n- Add one project detail.\n- '
        'Invite a teammate when the workspace has context.\n\nMeasure first '
        'invite completion, 24-hour return rate, and whether teams create a '
        'second project.',
  ),
  (
    id: 'command-risk',
    mine: true,
    text: "What's the risk if we delay the invite prompt?",
  ),
  (
    id: 'command-risk-reply',
    mine: false,
    text:
        'The main risk is reducing team creation for accounts that already '
        'know who they want to invite.\n\nTo protect that path, keep the '
        'invite action visible in the header and only change the primary '
        'empty-state guidance.',
  ),
];

class MessageScrollerCommandsExample extends StatelessWidget {
  const MessageScrollerCommandsExample({super.key});

  @override
  Widget build(BuildContext context) => MessageScrollerProvider(
    child: MessageScrollerDemoCard(
      title: 'Commands',
      description: 'Drive the transcript from outside.',
      action: const _CommandMenu(),
      caption: 'Use the controls to jump to any message in the conversation.',
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

class _CommandMenu extends StatelessWidget {
  const _CommandMenu();

  @override
  Widget build(BuildContext context) {
    final scroller = MessageScrollerProvider.of(context);
    return DropdownMenu(
      content: DropdownMenuContent(
        align: OverlayAlign.end,
        side: OverlaySide.bottom,
        width: Spacing.d256,
        children: [
          const DropdownMenuLabel(child: Text('Conversations')),
          for (final message in _messages)
            if (message.mine)
              DropdownMenuItem(
                onSelect: () =>
                    scroller.scrollToMessage(message.id, animate: true),
                child: Text(
                  messageScrollerShortLine(message.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        ],
      ),
      child: DropdownMenuTrigger.builder(
        builder: (context, menu) => Button(
          variant: ButtonVariant.secondary,
          onPressed: menu.toggle,
          child: const Text('Jump to...'),
        ),
      ),
    );
  }
}
