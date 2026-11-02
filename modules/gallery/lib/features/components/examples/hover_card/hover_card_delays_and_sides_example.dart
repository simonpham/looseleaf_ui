import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class HoverCardDelaysAndSidesExample extends StatelessWidget {
  const HoverCardDelaysAndSidesExample({super.key});

  static const _cards = [
    (
      label: 'Instant, left',
      open: 0,
      close: 100,
      side: OverlaySide.left,
      doodle: 'sun',
    ),
    (
      label: 'Default, bottom',
      open: 700,
      close: 300,
      side: OverlaySide.bottom,
      doodle: 'mushroom',
    ),
    (
      label: 'Patient, right',
      open: 1200,
      close: 300,
      side: OverlaySide.right,
      doodle: 'star',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Spacing.d16,
      runSpacing: Spacing.d16,
      children: [
        for (final card in _cards)
          HoverCard(
            openDelay: Duration(milliseconds: card.open),
            closeDelay: Duration(milliseconds: card.close),
            content: HoverCardContent(
              side: card.side,
              align: OverlayAlign.start,
              seed: card.label,
              width: Spacing.d224,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HoverCardMedia(
                    height: Spacing.d96,
                    child: Doodle(card.doodle, size: 72),
                  ),
                  HoverCardCaption(Text(card.label)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.d4,
                    ),
                    child: Text(
                      'open ${card.open} ms, close ${card.close} ms',
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
              variant: ButtonVariant.outline,
              onPressed: () {},
              child: Text(card.label),
            ),
          ),
      ],
    );
  }
}
