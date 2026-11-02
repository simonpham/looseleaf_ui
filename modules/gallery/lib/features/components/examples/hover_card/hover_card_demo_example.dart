import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class HoverCardDemoExample extends StatelessWidget {
  const HoverCardDemoExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final small = theme.typography.interface(cssSize: 14);
    final muted = theme.colors.inkMuted;
    return HoverCard(
      content: HoverCardContent(
        width: Spacing.d320,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d16,
          children: [
            const Avatar(children: [AvatarFallback(child: Text('VC'))]),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d4,
                children: [
                  Text(
                    '@nextjs',
                    style: small.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'The React Framework – created and maintained by @vercel.',
                    style: small,
                  ),
                  Row(
                    spacing: Spacing.d4,
                    children: [
                      InkIcon('calendar', size: Spacing.d16, color: muted),
                      Text(
                        'Joined December 2021',
                        style: theme.typography.interface(
                          cssSize: 12,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      child: Button(
        variant: ButtonVariant.link,
        onPressed: () {},
        child: const Text('@nextjs'),
      ),
    );
  }
}
