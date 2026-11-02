import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A letter in the list: who it is from and when, the subject, and two
/// lines of its start. Unread letters get a marker dot and a bold name;
/// the open one, hover and focus lay the highlighter.
class Sidebar09MailRow extends StatelessWidget {
  const Sidebar09MailRow({
    super.key,
    required this.mail,
    required this.unread,
    required this.current,
    required this.onPressed,
  });

  final Mail mail;
  final bool unread;
  final bool current;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final small = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 14,
      cssLineHeight: 1.25,
      color: theme.colors.inkMuted,
    );
    final body = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 14,
      cssLineHeight: 1.25,
      color: theme.colors.ink,
    );
    return Semantics(
      container: true,
      button: true,
      selected: current,
      label: switch (unread) {
        true => 'Unread.',
        false => null,
      },
      child: InkInteraction(
        onActivate: onPressed,
        builder: (context, states) => SidebarSwipe(
          on:
              current ||
              states.contains(InkState.hovered) ||
              states.contains(InkState.focused),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.d16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d6,
              children: [
                Row(
                  spacing: Spacing.d8,
                  children: [
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (unread)
                            PositionedDirectional(
                              start: -Spacing.d14,
                              top: Spacing.d3,
                              child: InkIcon(
                                'dot',
                                size: Spacing.d12,
                                color: theme.colors.marker,
                              ),
                            ),
                          Text(
                            mail.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: body.copyWith(
                              fontWeight: switch (unread) {
                                true => FontWeight.w700,
                                false => FontWeight.w400,
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(mail.date, style: small),
                  ],
                ),
                Text(
                  mail.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: body.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  mail.teaser,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: small,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
