import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Five features pinned to a corkboard on five kinds of paper: ruled
/// kickoff notes, a ticked sticky note, a polaroid, a receipt of versions
/// and a ticket. One column, two from 576 px, and a six-column bento from
/// 896 px.
///
/// Mirrors upstream `src/blocks/features-01/components/features-01-bento.tsx`.
class Features01Bento extends StatelessWidget {
  const Features01Bento({super.key, required this.width});

  /// The block's width, which the container breakpoints read (upstream's
  /// `@container`).
  final double width;

  static const double _receiptWidth = 288;
  static const double _noteWidth = 224;
  static const double _photoWidth = 256;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    Widget fit(double most, Widget Function(double width) build) =>
        LayoutBuilder(
          builder: (context, constraints) => Center(
            child: build(math.min(most, constraints.maxWidth)),
          ),
        );
    final write = Paper(
      rules: RuleName.ruled,
      mirrorRules: Directionality.of(context) == TextDirection.rtl,
      tiltDegrees: 0.4,
      fastener: FastenerKind.clip,
      seed: 'bento-write',
      padding: const EdgeInsetsDirectional.only(
        top: Spacing.d16,
        end: Spacing.d24,
        bottom: Spacing.d28,
        start: Spacing.d56,
      ),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 17,
          cssLineHeight: 28 / 17,
          color: theme.colors.ink,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kickoff notes / Tuesday',
              style: theme.typography.face(
                KevinSansFace.type,
                cssSize: 14,
                cssLineHeight: 28 / 14,
                color: theme.colors.pencilText,
              ),
            ),
            Semantics(
              header: true,
              child: Text(
                'Write together',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 30,
                  cssLineHeight: 28 / 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'Everyone edits the same page at once. Name flags show who is where, and nobody has to say “are you in the doc?” ever again.',
              style: TextStyle(color: theme.colors.inkSoft),
            ),
            const SizedBox(height: Spacing.d28),
            const Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Ship the '),
                Underline(tone: MarkPen.blue, child: Text('tape update')),
                Text(' before Friday'),
              ],
            ),
            const Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Spacing.d4,
              children: [
                Text('Ask Ada about the cover'),
                Ribbon(
                  variant: RibbonVariant.flag,
                  tone: RibbonTone.sky,
                  size: RibbonSize.sm,
                  child: Text('Ada'),
                ),
              ],
            ),
            const Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Strike(child: Text('Rename the tabs')),
                Text(' done, thanks Jo'),
              ],
            ),
            const Text('Draw something for the launch post'),
          ],
        ),
      ),
    );
    final tick = fit(
      _noteWidth,
      (width) => StickyNote(
        color: StickyColor.green,
        done: true,
        fastener: FastenerKind.pin,
        seed: 'bento-tick',
        width: width,
        children: [
          StickyNoteTitle(
            Semantics(header: true, child: const Text('Tick things off')),
          ),
          StickyNoteContent(
            Text(
              'Tasks live next to the notes they came from.',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 18,
                cssLineHeight: 28 / 18,
              ),
            ),
          ),
        ],
      ),
    );
    final draw = fit(
      _photoWidth,
      (width) => Polaroid(
        width: width,
        tape: PaperTape.top,
        tapeKind: TapeKind.washiStripes,
        seed: 'bento-draw',
        children: [
          const PolaroidImage(scene: PolaroidScene.night, seed: 'bento-night'),
          PolaroidCaption(
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d4,
              children: [
                Semantics(header: true, child: const Text('Draw on anything')),
                Text(
                  'A sketch pad on every page.',
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 14,
                    cssLineHeight: 1.25,
                    color: theme.colors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    final receipt = LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: AlignmentDirectional.topStart,
        child: Receipt(
          seed: 'bento-receipt',
          width: math.min(_receiptWidth, constraints.maxWidth),
          children: [
            ReceiptHeader(
              children: [
                Semantics(header: true, child: const Text('Version history')),
                const Text('every draft, itemised'),
              ],
            ),
            const ReceiptLines(
              children: [
                ReceiptLine(price: Text('9:02'), child: Text('Draft one')),
                ReceiptLine(price: Text('9:40'), child: Text('Ada’s edits')),
                ReceiptLine(
                  price: Text('11:15'),
                  child: Text('Cut the intro'),
                ),
                ReceiptLine(
                  price: Text('14:30'),
                  child: Text('Final, really'),
                ),
              ],
            ),
            const ReceiptTotal(
              label: Text('Pages kept'),
              circled: ReceiptPen.redfelt,
              seed: 'bento-total',
              child: Text('12'),
            ),
          ],
        ),
      ),
    );
    final ticket = Center(
      child: Ticket(
        stock: StockName.indexCard,
        seed: 'bento-ticket',
        children: [
          TicketBody(
            children: [
              TicketTitle(
                Semantics(header: true, child: const Text('Works offline')),
              ),
              const TicketDescription(
                Text('Plane, train, tunnel: keep writing'),
              ),
            ],
          ),
          const TicketStub(
            children: [
              TicketDescription(Text('admit')),
              TicketNumber(Text('No. 0007')),
            ],
          ),
        ],
      ),
    );
    final pad = switch (width >= 576) {
      true => Spacing.d44,
      false => Spacing.d36,
    };
    Widget pair(Widget start, Widget end, {int startFlex = 1}) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d36,
      children: [
        Expanded(flex: startFlex, child: start),
        Expanded(child: end),
      ],
    );
    final layout = switch (width) {
      >= 896 => [
        pair(
          write,
          Column(
            spacing: Spacing.d36,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [tick, draw],
          ),
          startFlex: 2,
        ),
        pair(receipt, ticket),
      ],
      >= 576 => [write, pair(tick, draw), pair(receipt, ticket)],
      _ => [write, tick, draw, receipt, ticket],
    };
    return Stack(
      children: [
        const Positioned.fill(
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: Corkboard(
                label: 'Cork',
                disabled: true,
                seed: 'features-cork',
                children: [],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d36,
            children: layout,
          ),
        ),
      ],
    );
  }
}
