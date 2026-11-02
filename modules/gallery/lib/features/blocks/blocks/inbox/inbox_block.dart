import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/inbox/inbox.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A mail app on paper: a letter tray with Inbox, Archive and Trash, a
/// search and an unread filter, and the open letter on its own sheet,
/// where it can be archived, deleted, starred, marked and answered. On a
/// phone the list and the letter take turns.
///
/// Mirrors upstream `src/blocks/inbox/page.tsx`.
class InboxBlock extends StatefulWidget {
  const InboxBlock({super.key});

  @override
  State<InboxBlock> createState() => _InboxBlockState();
}

class _InboxBlockState extends State<InboxBlock> {
  final _query = TextEditingController();
  List<InboxMail> _all = inboxMails;
  InboxFolder _folder = InboxFolder.inbox;
  bool _unreadOnly = false;
  String? _openId;
  String _message = '';

  static const double _maxWidth = 1152;
  static const double _md = 768;
  static const double _sm = 640;
  static const double _lg = 1024;
  static const double _height = 608;
  static const double _trayWidth = 368;
  static const double _minHeight = 384;

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

  List<InboxMail> get _visible {
    final query = _query.text.trim().toLowerCase();
    return [
      for (final mail in _all)
        if (mail.folder == _folder &&
            (!_unreadOnly || mail.unread) &&
            (query.isEmpty ||
                '${mail.from} ${mail.subject} ${mail.body.join(' ')}'
                    .toLowerCase()
                    .contains(query)))
          mail,
    ];
  }

  void _patch(String id, InboxMail Function(InboxMail mail) change) {
    _all = [
      for (final mail in _all)
        switch (mail.id == id) {
          true => change(mail),
          false => mail,
        },
    ];
  }

  void _open(String id) => setState(() {
    _openId = id;
    _patch(id, (mail) => mail.copyWith(unread: false));
  });

  void _file(
    InboxMail mail,
    InboxFolder to,
    String verb, {
    required bool phone,
  }) {
    final visible = _visible;
    final at = visible.indexWhere((other) => other.id == mail.id);
    final next =
        visible.elementAtOrNull(at + 1) ?? visible.elementAtOrNull(at - 1);
    setState(() {
      _patch(mail.id, (mail) => mail.copyWith(folder: to));
      _message = '$verb “${mail.subject}”.';
      _openId = null;
      if (next == null || phone) return;
      _openId = next.id;
      _patch(next.id, (mail) => mail.copyWith(unread: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final visible = _visible;
    final open = _all
        .where(
          (mail) =>
              mail.id == _openId && visible.any((other) => other.id == mail.id),
        )
        .firstOrNull;
    final unreadCount = _all
        .where((mail) => mail.folder == InboxFolder.inbox && mail.unread)
        .length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final phone = width < _md;
        final tray = InboxTray(
          folder: _folder,
          onFolder: (folder) => setState(() {
            _folder = folder;
            _openId = null;
          }),
          unreadCount: unreadCount,
          query: _query,
          unreadOnly: _unreadOnly,
          onUnreadOnly: (only) => setState(() => _unreadOnly = only),
          visible: visible,
          openId: open?.id,
          onOpen: _open,
          bounded: !phone,
        );
        final pane = switch (open) {
          null => const InboxNothingOpen(),
          final mail => InboxReadingPane(
            key: ValueKey(mail.id),
            mail: mail,
            phone: phone,
            wide: width >= _sm,
            onBack: () => setState(() => _openId = null),
            onArchive: () =>
                _file(mail, InboxFolder.archive, 'Archived', phone: phone),
            onRestore: () => _file(
              mail,
              InboxFolder.inbox,
              'Moved to the inbox:',
              phone: phone,
            ),
            onTrash: () =>
                _file(mail, InboxFolder.trash, 'Deleted', phone: phone),
            onUnread: (unread) => setState(() {
              _patch(mail.id, (mail) => mail.copyWith(unread: unread));
              _message =
                  'Marked “${mail.subject}” as ${switch (unread) {
                    true => 'unread',
                    false => 'read',
                  }}.';
            }),
            onStar: (starred) => setState(
              () => _patch(mail.id, (mail) => mail.copyWith(starred: starred)),
            ),
            onReply: (text) => setState(() {
              _patch(
                mail.id,
                (mail) => mail.copyWith(replies: [...mail.replies, text]),
              );
              _message = 'Reply sent to ${mail.firstName}.';
            }),
          ),
        };
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Padding(
              padding: EdgeInsets.all(switch (width) {
                >= _lg => Spacing.d32,
                >= _sm => Spacing.d24,
                _ => Spacing.d16,
              }),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d16,
                children: [
                  Wrap(
                    spacing: Spacing.d12,
                    runSpacing: Spacing.d12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: Spacing.d16,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Marigold Paper Co.',
                                style: theme.typography.face(
                                  KevinSansFace.type,
                                  cssSize: 14,
                                  color: theme.colors.inkMuted,
                                ),
                              ),
                              Semantics(
                                header: true,
                                child: Text(
                                  'The post',
                                  style: theme.typography.face(
                                    KevinSansFace.script,
                                    cssSize: switch (width >= _sm) {
                                      true => 48,
                                      false => 36,
                                    },
                                    cssLineHeight: 1,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (width >= _sm)
                            const Sticker(
                              'envelope-heart',
                              size: 68,
                              seed: 'inbox-envelope',
                            ),
                        ],
                      ),
                      Text(
                        switch (unreadCount) {
                          0 => 'All read.',
                          1 => 'One letter is waiting.',
                          _ => '$unreadCount letters are waiting.',
                        },
                        style: TextStyle(color: theme.colors.inkMuted),
                      ),
                    ],
                  ),
                  switch (phone) {
                    true => ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: _minHeight),
                      child: switch (open) {
                        null => tray,
                        _ => pane,
                      },
                    ),
                    false => SizedBox(
                      height: _height,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Spacing.d16,
                        children: [
                          SizedBox(width: _trayWidth, child: tray),
                          Expanded(
                            child: switch (open) {
                              null => pane,
                              _ => SingleChildScrollView(child: pane),
                            },
                          ),
                        ],
                      ),
                    ),
                  },
                  Semantics(
                    liveRegion: true,
                    label: _message,
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
