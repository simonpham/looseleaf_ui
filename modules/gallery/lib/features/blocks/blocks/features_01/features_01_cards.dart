import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Three features on three index cards, each with a doodle and a link:
/// stacked, or in a row from 768 px wide with the middle card dropped.
///
/// Mirrors upstream `src/blocks/features-01/components/features-01-cards.tsx`.
class Features01Cards extends StatelessWidget {
  const Features01Cards({super.key, required this.width});

  /// The block's width, which the container breakpoints read (upstream's
  /// `@container`).
  final double width;

  static const _features = [
    (
      id: 'write',
      title: 'Write together',
      doodle: 'pencil',
      body: 'Everyone edits the same page at once, with little name flags for cursors. No more “which version is final?”',
      link: 'How writing works',
    ),
    (
      id: 'keep',
      title: 'Never lose a page',
      doodle: 'book',
      body: 'Every change is kept for a year. Wind a page back to last Tuesday, or lift a single paragraph out of it.',
      link: 'About history',
    ),
    (
      id: 'share',
      title: 'Share the good bits',
      doodle: 'paper-plane',
      body: 'Send one page, a whole notebook, or a single line. People without an account can read along.',
      link: 'About sharing',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final calm = PaperInk.calm(LooseleafTheme.of(context));
    final arrow = InkIcon(
      'arrow-right',
      flip: switch (Directionality.of(context)) {
        TextDirection.rtl => IconFlip.x,
        TextDirection.ltr => IconFlip.none,
      },
    );
    final cards = [
      for (final (index, feature) in _features.indexed)
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IndexCard(
                seed: 'feature-${feature.id}',
                tape: switch (feature.id) {
                  'keep' => PaperTape.top,
                  _ => null,
                },
                tapeKind: TapeKind.washiDots,
                fastener: switch (feature.id) {
                  'share' => FastenerKind.clip,
                  _ => null,
                },
                children: [
                  IndexCardHeader(
                    children: [
                      IndexCardTitle(
                        Semantics(header: true, child: Text(feature.title)),
                      ),
                    ],
                  ),
                  IndexCardContent(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d12,
                        children: [
                          Expanded(child: Text(feature.body)),
                          Padding(
                            padding: const EdgeInsets.only(top: Spacing.d2),
                            child: Doodle(
                              feature.doodle,
                              size: 56,
                              seed: 'doodle-${feature.id}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IndexCardFooter(
                    children: [
                      Flexible(
                        child: Button(
                          variant: ButtonVariant.link,
                          size: ButtonSize.sm,
                          onPressed: () {},
                          trailing: arrow,
                          child: Text(feature.link),
                        ),
                      ),
                      Text('no. ${'${index + 1}'.padLeft(4, '0')}'),
                    ],
                  ),
                ],
              ),
              if (feature.id == 'write' && !calm)
                const PositionedDirectional(
                  top: -Spacing.d8,
                  end: Spacing.d40,
                  child: PaperFastener(
                    kind: FastenerKind.pin,
                    seed: 'feature-write-pin',
                  ),
                ),
            ],
          ),
        ),
    ];
    return switch (width >= 768) {
      true => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d32,
        children: [
          for (final (index, card) in cards.indexed)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: switch (index) {
                    1 => Spacing.d32,
                    _ => 0,
                  },
                ),
                child: card,
              ),
            ),
        ],
      ),
      false => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d48,
        children: cards,
      ),
    };
  }
}
