import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/inbox/inbox.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One letter in the list: who, when, the subject and the first line,
/// bold with a blue dot while unread, swiped with highlighter while open.
///
/// Mirrors the row of `MailList` in upstream
/// `src/blocks/inbox/components/inbox-list.tsx`.
class InboxMailRow extends StatelessWidget {
  const InboxMailRow({
    super.key,
    required this.mail,
    required this.selected,
    required this.onOpen,
  });

  final InboxMail mail;
  final bool selected;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final weight = switch (mail.unread) {
      true => FontWeight.w700,
      false => FontWeight.w400,
    };
    return InkItem(
      size: ItemSize.sm,
      onPressed: onOpen,
      seed: 'inbox-row-${mail.id}',
      forcedStates: {if (selected) InkState.hovered},
      semanticLabel: switch (mail.unread) {
        true => 'Unread. ${mail.from}, ${mail.subject}',
        false => '${mail.from}, ${mail.subject}',
      },
      children: [
        ItemMedia(
          variant: ItemMediaVariant.icon,
          child: InkIcon(switch (mail.unread) {
            true => 'mail',
            false => 'mail-check',
          }),
        ),
        ItemContent(
          children: [
            ItemTitle(
              Row(
                spacing: Spacing.d12,
                children: [
                  Expanded(
                    child: Text(
                      mail.from,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: weight),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Spacing.d6,
                    children: [
                      if (mail.starred)
                        InkIcon(
                          'star',
                          size: Spacing.d14,
                          semanticLabel: 'Starred',
                          color: theme.colors.hiDeep,
                        ),
                      Text(
                        mail.date,
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              mail.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: 15,
                fontWeight: weight,
              ),
            ),
            ItemDescription(Text(mail.body.first, maxLines: 1)),
          ],
        ),
        if (mail.unread)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.d8),
            child: SizedBox.square(
              dimension: Spacing.d8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.inkYou,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
