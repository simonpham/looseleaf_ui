import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/testimonials_01/testimonials_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Six kind words pinned up on six kinds of paper: sticky notes, a torn
/// sheet, a polaroid, a napkin and an index card. One column, then two
/// from 672 px and three from 896 px, the middle column dropped a little.
///
/// Mirrors upstream
/// `src/blocks/testimonials-01/components/testimonials-01-wall.tsx`.
class Testimonials01Wall extends StatelessWidget {
  const Testimonials01Wall({super.key});

  static const double _noteWidth = 256;
  static const double _sheetWidth = 384;
  static const double _napkinWidth = 288;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final quoteStyle = theme.typography.face(
      KevinSansFace.script,
      cssSize: 24,
      cssLineHeight: 1.15,
    );
    Widget fit(double most, Widget Function(double width) build) =>
        LayoutBuilder(
          builder: (context, constraints) => Center(
            child: build(math.min(most, constraints.maxWidth)),
          ),
        );
    final items = <Widget>[
      fit(
        _noteWidth,
        (width) => StickyNote(
          fastener: FastenerKind.pin,
          seed: 't-priya',
          width: width,
          children: [
            Text(
              '“I stopped losing meeting notes. That’s it. That’s the review.”',
              style: quoteStyle,
            ),
            const Padding(
              padding: EdgeInsets.only(top: Spacing.d8),
              child: Testimonials01Author('Priya Nair', 'ops lead at Kiln'),
            ),
          ],
        ),
      ),
      fit(
        _sheetWidth,
        (width) => SizedBox(
          width: width,
          child: const Paper(
            edge: EdgeSpec(bottom: EdgeKind.torn),
            tape: PaperTape.corner,
            seed: 't-tomas',
            padding: EdgeInsets.fromLTRB(
              Spacing.d32,
              Spacing.d40,
              Spacing.d32,
              Spacing.d36,
            ),
            child: Quote(
              children: [
                QuoteText(
                  child: Text(
                    'We moved forty people off three different tools in a week. Nobody asked to go back, which has never happened before.',
                  ),
                ),
                QuoteAttribution(
                  child: Testimonials01Author(
                    'Tomas Berg',
                    'COO at Northwind Ink',
                    cssSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      fit(
        _noteWidth,
        (width) => Polaroid(
          width: width,
          tape: PaperTape.top,
          tapeKind: TapeKind.washiDots,
          seed: 't-lena',
          children: const [
            PolaroidImage(scene: PolaroidScene.sea, seed: 't-sea'),
            PolaroidCaption(
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d4,
                children: [
                  Text('“finally, a place we all write”'),
                  Testimonials01Author(
                    'Lena Fischer',
                    'Brindle',
                    cssSize: 14,
                    cssLineHeight: 1.25,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      fit(
        _napkinWidth,
        (width) => Napkin(
          stain: true,
          seed: 't-omar',
          width: width,
          children: const [
            NapkinContent(
              Text(
                '“We run the whole café off one page. The tape is a nice touch.”',
              ),
            ),
            Testimonials01Author('Omar Haddad', 'owner, The Tea Room'),
          ],
        ),
      ),
      fit(
        _noteWidth,
        (width) => StickyNote(
          color: StickyColor.pink,
          tape: PaperTape.top,
          tapeKind: TapeKind.washiStripes,
          seed: 't-yuki',
          width: width,
          children: [
            Text(
              '“It looks like something a person made, and works like something a team built.”',
              style: quoteStyle,
            ),
            const Padding(
              padding: EdgeInsets.only(top: Spacing.d8),
              child: Testimonials01Author(
                'Yuki Tanaka',
                'designer at Loom & Lantern',
              ),
            ),
          ],
        ),
      ),
      const Center(
        child: IndexCard(
          seed: 't-kofi',
          fastener: FastenerKind.clip,
          minHeight: Spacing.d40,
          children: [
            IndexCardHeader(children: [IndexCardTitle(Text('Kofi says'))]),
            IndexCardContent(
              children: [
                Text(
                  '“Search finds the thing I half-remember. It’s witchcraft, honestly.”',
                ),
              ],
            ),
            IndexCardFooter(
              children: [
                Flexible(
                  child: Testimonials01Author(
                    'Kofi Mensah',
                    'founder, Salt Studio',
                    cssSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = switch (width) {
          >= 896 => 3,
          >= 672 => 2,
          _ => 1,
        };
        final dropped = columns == 3;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d56,
          children: [
            for (var start = 0; start < items.length; start += columns)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d32,
                children: [
                  for (var index = start; index < start + columns; index++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: switch (dropped && index % 3 == 1) {
                            true => Spacing.d40,
                            false => 0,
                          },
                        ),
                        child: items.elementAtOrNull(index) ?? const SizedBox(),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
