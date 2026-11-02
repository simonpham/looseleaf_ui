import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class HoverCardTapedStickerExample extends StatelessWidget {
  const HoverCardTapedStickerExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d4,
      children: [
        const Text('Read the notes for'),
        HoverCard(
          content: HoverCardContent(
            tape: PaperTape.top,
            tiltDegrees: -1.2,
            seed: 'release',
            width: Spacing.d288,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HoverCardMedia(child: Sticker('rocket', size: 84)),
                const HoverCardCaption(Text('v1.0 is out')),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.d4,
                  ),
                  child: Text(
                    'Forty-odd components, every line drawn by hand.',
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
            child: const Text('Looseleaf 1.0'),
          ),
        ),
      ],
    );
  }
}
