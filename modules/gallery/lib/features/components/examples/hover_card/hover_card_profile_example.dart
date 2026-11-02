import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class HoverCardProfileExample extends StatelessWidget {
  const HoverCardProfileExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d4,
      children: [
        const Text('Made by'),
        HoverCard(
          content: HoverCardContent(
            seed: 'profile',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HoverCardMedia(child: Doodle('flower', size: 88)),
                const HoverCardCaption(Text('@looseleaf')),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.d4,
                  ),
                  child: Text(
                    'shadcn/ui, drawn by hand. Joined September 2026.',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          child: Button(
            variant: ButtonVariant.link,
            onPressed: () {},
            child: const Text('@looseleaf'),
          ),
        ),
      ],
    );
  }
}
