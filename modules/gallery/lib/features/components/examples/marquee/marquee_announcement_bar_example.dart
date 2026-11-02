import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarqueeAnnouncementBarExample extends StatelessWidget {
  const MarqueeAnnouncementBarExample({super.key});

  static const _maxWidth = 768.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final nav = theme.typography.face(KevinSansFace.script, cssSize: 24);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          Marquee(
            label: 'Announcements',
            speed: 55,
            tape: TapeKind.washiStripes,
            color: Accent.tangerine,
            children: [
              MarqueeItem(
                Button(
                  variant: ButtonVariant.link,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Spring sale: everything ten off'),
                ),
              ),
              MarqueeItem(
                Button(
                  variant: ButtonVariant.link,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Free shipping over 40'),
                ),
              ),
              const MarqueeItem(Text('New: the felt-tip collection')),
            ],
          ),
          Semantics(
            label: 'Main',
            container: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
              child: Wrap(
                spacing: Spacing.d24,
                runSpacing: Spacing.d8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Looseleaf & Co.',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 30,
                    ),
                  ),
                  for (final page in ['Shop', 'Journal', 'About'])
                    Semantics(
                      link: true,
                      child: GestureDetector(
                        onTap: () {},
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(page, style: nav),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
