import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An open letter: who sent it and when, its lines, and a button to mark
/// it unread again.
class Sidebar09Letter extends StatelessWidget {
  const Sidebar09Letter({
    super.key,
    required this.mail,
    required this.onMarkUnread,
  });

  final Mail mail;
  final VoidCallback onMarkUnread;

  /// `max-w-prose`.
  static const double _maxWidth = 600;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      label: mail.subject,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d12,
            children: [
              Text(
                '${mail.name} <${mail.email}> · ${mail.date}',
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 14,
                  color: theme.colors.inkMuted,
                ),
              ),
              for (final line in mail.teaser.split('\n'))
                Text(
                  line,
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 16,
                    color: theme.colors.ink,
                  ),
                ),
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: onMarkUnread,
                child: const Text('Mark as unread'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
