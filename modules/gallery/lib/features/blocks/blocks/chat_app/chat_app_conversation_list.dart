import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/chat_app/chat_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The chats on a binder-clipped pad: a search, All or Unread, and one
/// row per conversation with its last line, time and unread count.
///
/// Mirrors `ChatAppConversationList` in upstream
/// `src/blocks/chat-app/components/chat-app-conversation-list.tsx`.
class ChatAppConversationList extends StatefulWidget {
  const ChatAppConversationList({
    super.key,
    required this.conversations,
    required this.activeId,
    required this.onSelect,
  });

  final List<ChatAppConversation> conversations;
  final String activeId;
  final ValueChanged<String> onSelect;

  @override
  State<ChatAppConversationList> createState() =>
      _ChatAppConversationListState();
}

class _ChatAppConversationListState extends State<ChatAppConversationList> {
  final _query = TextEditingController();
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQuery);
  }

  @override
  void dispose() {
    _query
      ..removeListener(_onQuery)
      ..dispose();
    super.dispose();
  }

  void _onQuery() => setState(() {});

  Widget _row(ChatAppConversation conversation) {
    final theme = LooseleafTheme.of(context);
    final unread = conversation.unread > 0;
    return InkItem(
      key: ValueKey(conversation.id),
      size: ItemSize.sm,
      seed: conversation.id,
      onPressed: () => widget.onSelect(conversation.id),
      forcedStates: {
        if (conversation.id == widget.activeId) InkState.hovered,
      },
      children: [
        ItemMedia(child: ChatAppFace(conversation: conversation)),
        ItemContent(
          children: [
            ItemTitle(
              Text(
                conversation.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: switch (unread) {
                    true => FontWeight.w800,
                    false => FontWeight.w700,
                  },
                ),
              ),
            ),
            ItemDescription(Text(conversation.snippet, maxLines: 1)),
          ],
        ),
        ItemActions(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: Spacing.d4,
              children: [
                Text(
                  conversation.time,
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
                if (unread)
                  Badge(
                    size: BadgeSize.sm,
                    semanticLabel: '${conversation.unread} unread',
                    child: Text('${conversation.unread}'),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final query = _query.text.trim();
    final lowered = query.toLowerCase();
    final rows = [
      for (final conversation in widget.conversations)
        if ((!_unreadOnly || conversation.unread > 0) &&
            (lowered.isEmpty ||
                '${conversation.name} ${conversation.snippet}'
                    .toLowerCase()
                    .contains(lowered)))
          conversation,
    ];
    final unreadTotal = widget.conversations.fold(
      0,
      (total, conversation) => total + conversation.unread,
    );
    return Paper(
      stock: StockName.pad,
      rules: RuleName.none,
      tiltDegrees: -0.3,
      fastener: FastenerKind.binderClip,
      seed: 'chat-list',
      padding: const EdgeInsets.only(top: Spacing.d24, bottom: Spacing.d12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
            child: Row(
              spacing: Spacing.d12,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      'Chats',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 27.2,
                        cssLineHeight: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (unreadTotal > 0)
                  Badge(
                    variant: BadgeVariant.secondary,
                    child: Text('$unreadTotal new'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d10,
              children: [
                InputGroup(
                  children: [
                    const InputGroupAddon(child: InkIcon('search')),
                    InputGroupInput(
                      controller: _query,
                      placeholder: 'Search chats',
                      semanticLabel: 'Search chats',
                    ),
                  ],
                ),
                ToggleGroup<bool>(
                  type: ToggleGroupType.single,
                  size: ToggleSize.sm,
                  variant: ToggleVariant.outline,
                  semanticLabel: 'Show',
                  value: {_unreadOnly},
                  onChanged: (picked) => setState(
                    () => _unreadOnly = picked.singleOrNull ?? false,
                  ),
                  children: const [
                    ToggleGroupItem(value: false, child: Text('All')),
                    ToggleGroupItem(value: true, child: Text('Unread')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ScrollArea(
              bleed: true,
              child: switch (rows.isEmpty) {
                true => Empty(
                  seed: 'chat-none',
                  children: [
                    EmptyHeader(
                      children: [
                        const EmptyMedia(pose: 'search', size: 88),
                        const EmptyTitle(child: Text('No chats match')),
                        EmptyDescription(
                          child: Text(switch (query.isEmpty) {
                            true => 'You are all caught up.',
                            false =>
                              'Nothing says “$query”. Try a shorter word.',
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                false => ItemGroup(
                  ruled: true,
                  semanticLabel: 'Conversations',
                  children: [for (final row in rows) _row(row)],
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
