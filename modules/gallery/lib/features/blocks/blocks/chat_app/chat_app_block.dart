import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/chat_app/chat_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A messaging app: the chats on a binder-clipped pad beside the open
/// thread on a taped card. Sending gets a scripted reply, typed word by
/// word, that can be stopped. Below 768 px the list and the thread take
/// turns.
///
/// Mirrors upstream `src/blocks/chat-app/page.tsx` and
/// `src/blocks/chat-app/components/chat-app-state.ts`.
class ChatAppBlock extends StatefulWidget {
  const ChatAppBlock({super.key, this.onSend});

  /// Called with the conversation, the text and the files of every send.
  final void Function(
    String conversationId,
    String text,
    List<ChatAppFile> files,
  )?
  onSend;

  @override
  State<ChatAppBlock> createState() => _ChatAppBlockState();
}

class _ChatAppBlockState extends State<ChatAppBlock> {
  List<ChatAppConversation> _conversations = chatAppConversations;
  String _activeId = chatAppConversations.first.id;
  ({String id, PromptInputStatus phase})? _stream;
  String _announce = '';
  bool _showThread = false;
  int _counter = 0;
  final List<Timer> _timers = [];

  static const double _wideFrom = 768;
  static const double _height = 800;
  static const double _minListWidth = 256;
  static const double _maxListWidth = 336;
  static const double _listShare = 0.4;

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  void _clear() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void _stop() {
    _clear();
    setState(() => _stream = null);
  }

  void _update(
    String id,
    ChatAppConversation Function(ChatAppConversation) change,
  ) {
    _conversations = [
      for (final conversation in _conversations)
        switch (conversation.id == id) {
          true => change(conversation),
          false => conversation,
        },
    ];
  }

  void _select(String id) {
    if (id == _activeId) {
      setState(() => _showThread = true);
      return;
    }
    _clear();
    setState(() {
      _stream = null;
      _activeId = id;
      _announce = '';
      _showThread = true;
      _update(id, (conversation) => conversation.copyWith(unread: 0));
    });
  }

  void _send(String text, List<ChatAppFile> files) {
    final id = _activeId;
    final conversation = _conversations
        .where((each) => each.id == id)
        .firstOrNull;
    if (conversation == null) return;
    widget.onSend?.call(id, text, files);
    final n = _counter++;
    final theirs = 're-$n';
    setState(() {
      _update(
        id,
        (each) => each.copyWith(
          time: 'now',
          turns: [
            ...each.turns,
            ChatAppTurn(
              id: 'me-$n',
              mine: true,
              time: 'now',
              parts: [
                ChatAppText(switch (text.isEmpty) {
                  true => '(the files)',
                  false => text,
                }),
              ],
              files: files,
            ),
          ],
        ),
      );
      _stream = (id: id, phase: PromptInputStatus.submitted);
      _announce = '';
    });
    final steps = chatAppReplySteps(conversation.reply);
    var at = const Duration(milliseconds: 700);
    _timers.add(
      Timer(
        at,
        () => setState(() {
          _stream = (id: id, phase: PromptInputStatus.streaming);
          _update(
            id,
            (each) => each.copyWith(
              turns: [
                ...each.turns,
                ChatAppTurn(
                  id: theirs,
                  mine: false,
                  who: conversation.replyFrom,
                  time: 'now',
                  parts: const [],
                ),
              ],
            ),
          );
        }),
      ),
    );
    for (final (i, step) in steps.indexed) {
      at += step.wait;
      _timers.add(
        Timer(
          at,
          () => setState(() {
            _update(
              id,
              (each) => each.copyWith(
                turns: [
                  for (final turn in each.turns)
                    switch (turn.id == theirs) {
                      true => turn.withParts(step.apply(turn.parts)),
                      false => turn,
                    },
                ],
              ),
            );
            if (i < steps.length - 1) return;
            _stream = null;
            _announce = '${conversation.name} replied';
          }),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _conversations
        .where((each) => each.id == _activeId)
        .firstOrNull;
    final status = switch (_stream) {
      (:final id, :final phase) when id == _activeId => phase,
      _ => PromptInputStatus.ready,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideFrom;
        final list = ChatAppConversationList(
          conversations: _conversations,
          activeId: _activeId,
          onSelect: _select,
        );
        final thread = switch (active) {
          null => const SizedBox.shrink(),
          final conversation => ChatAppThread(
            key: ValueKey(conversation.id),
            conversation: conversation,
            status: status,
            announce: _announce,
            onSend: _send,
            onStop: _stop,
            onBack: () => setState(() => _showThread = false),
            wide: wide,
          ),
        };
        return SizedBox(
          height: _height,
          child: Padding(
            padding: switch (wide) {
              true => const EdgeInsets.fromLTRB(
                Spacing.d24,
                Spacing.d48,
                Spacing.d24,
                Spacing.d24,
              ),
              false => const EdgeInsets.fromLTRB(
                Spacing.d16,
                Spacing.d40,
                Spacing.d16,
                Spacing.d16,
              ),
            },
            child: switch (wide) {
              true => Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d24,
                children: [
                  SizedBox(
                    width: (constraints.maxWidth * _listShare).clamp(
                      _minListWidth,
                      _maxListWidth,
                    ),
                    child: list,
                  ),
                  Expanded(child: thread),
                ],
              ),
              false => switch (_showThread) {
                true => thread,
                false => list,
              },
            },
          ),
        );
      },
    );
  }
}
