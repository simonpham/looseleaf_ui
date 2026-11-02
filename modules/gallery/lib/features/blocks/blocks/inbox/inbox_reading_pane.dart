import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/inbox/inbox.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An open letter on a sheet of its own: what to do with it, the subject,
/// who sent it, the letter, its attachments, your replies and a reply box.
///
/// Mirrors `ReadingPane` in upstream
/// `src/blocks/inbox/components/inbox-reading-pane.tsx`.
class InboxReadingPane extends StatefulWidget {
  const InboxReadingPane({
    super.key,
    required this.mail,
    required this.phone,
    required this.wide,
    required this.onBack,
    required this.onArchive,
    required this.onRestore,
    required this.onTrash,
    required this.onUnread,
    required this.onStar,
    required this.onReply,
  });

  final InboxMail mail;

  /// Shows the way back to the list (the list and the letter take turns).
  final bool phone;

  /// Spells out the action buttons next to their icons.
  final bool wide;

  final VoidCallback onBack;
  final VoidCallback onArchive;
  final VoidCallback onRestore;
  final VoidCallback onTrash;
  final ValueChanged<bool> onUnread;
  final ValueChanged<bool> onStar;
  final ValueChanged<String> onReply;

  @override
  State<InboxReadingPane> createState() => _InboxReadingPaneState();
}

class _InboxReadingPaneState extends State<InboxReadingPane> {
  final _draft = TextEditingController();
  final _replyFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _draft.addListener(_onDraft);
  }

  @override
  void dispose() {
    _draft
      ..removeListener(_onDraft)
      ..dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  void _onDraft() => setState(() {});

  void _send() {
    final text = _draft.text.trim();
    if (text.isEmpty) return;
    widget.onReply(text);
    _draft.clear();
    _replyFocus.requestFocus();
  }

  Widget _action(String icon, String label, VoidCallback onPressed) =>
      switch (widget.wide) {
        true => Button(
          variant: ButtonVariant.outline,
          size: ButtonSize.sm,
          onPressed: onPressed,
          leading: InkIcon(icon),
          child: Text(label),
        ),
        false => Button(
          variant: ButtonVariant.outline,
          size: ButtonSize.iconSm,
          semanticLabel: label,
          onPressed: onPressed,
          child: InkIcon(icon),
        ),
      };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final mail = widget.mail;
    final muted = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    return Paper(
      tilt: false,
      seed: 'inbox-${mail.id}',
      padding: switch (widget.wide) {
        true => const EdgeInsets.all(Spacing.d32),
        false => const EdgeInsets.all(Spacing.d20),
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          Wrap(
            spacing: Spacing.d8,
            runSpacing: Spacing.d8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (widget.phone)
                Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.sm,
                  onPressed: widget.onBack,
                  leading: const InkIcon('arrow-left'),
                  child: const Text('Back to the list'),
                ),
              Semantics(
                container: true,
                label: 'What to do with this letter',
                child: Wrap(
                  spacing: Spacing.d4,
                  runSpacing: Spacing.d4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    switch (mail.folder) {
                      InboxFolder.inbox => _action(
                        'archive',
                        'Archive',
                        widget.onArchive,
                      ),
                      _ => _action('inbox', 'Move to inbox', widget.onRestore),
                    },
                    if (mail.folder != InboxFolder.trash)
                      _action('trash', 'Delete', widget.onTrash),
                    switch (mail.unread) {
                      true => _action(
                        'mail-check',
                        'Read',
                        () => widget.onUnread(false),
                      ),
                      false => _action(
                        'mail',
                        'Unread',
                        () => widget.onUnread(true),
                      ),
                    },
                    Toggle(
                      variant: ToggleVariant.outline,
                      size: ToggleSize.sm,
                      semanticLabel: 'Star',
                      value: mail.starred,
                      onChanged: widget.onStar,
                      child: const InkIcon('star'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Semantics(
            header: true,
            child: Text(
              mail.subject,
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: switch (widget.wide) {
                  true => 36,
                  false => 30,
                },
                cssLineHeight: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Row(
            spacing: Spacing.d12,
            children: [
              ExcludeSemantics(
                child: Avatar(
                  size: AvatarSize.lg,
                  children: [AvatarFallback(name: mail.from)],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mail.from,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${mail.address} · ${mail.date}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Separator(variant: SeparatorVariant.dashed),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d12,
            children: [
              for (final paragraph in mail.body)
                Text(
                  paragraph,
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 17,
                    cssLineHeight: 1.625,
                  ),
                ),
            ],
          ),
          if (mail.attachments.isNotEmpty)
            Semantics(
              container: true,
              label: 'Attachments',
              child: Wrap(
                spacing: Spacing.d8,
                runSpacing: Spacing.d8,
                children: [
                  for (final attachment in mail.attachments)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colors.hiSelect.withValues(
                          alpha: theme.colors.hiSelect.a * 0.6,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.d10,
                          vertical: Spacing.d4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: Spacing.d6,
                          children: [
                            const InkIcon('paperclip', size: Spacing.d14),
                            Text(
                              attachment,
                              style: theme.typography.face(
                                KevinSansFace.hand,
                                cssSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (mail.replies.isNotEmpty)
            Semantics(
              container: true,
              label: 'Your replies',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d8,
                children: [
                  for (final reply in mail.replies)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: Spacing.d24,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: BorderDirectional(
                            start: BorderSide(
                              color: theme.colors.inkYou,
                              width: Spacing.d2,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: Spacing.d12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('You wrote, just now', style: muted),
                              Text(
                                reply,
                                style: TextStyle(color: theme.colors.inkYou),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: Spacing.d8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d8,
              children: [
                Label(
                  focusNode: _replyFocus,
                  child: Text('Reply to ${mail.firstName}'),
                ),
                Textarea(
                  controller: _draft,
                  focusNode: _replyFocus,
                  placeholder: 'Dear ${mail.firstName},',
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Button(
                    disabled: _draft.text.trim().isEmpty,
                    onPressed: _send,
                    leading: const InkIcon('send'),
                    child: const Text('Send'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
