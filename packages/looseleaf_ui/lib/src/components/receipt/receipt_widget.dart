import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Thermal till paper: pinked (or perforated, torn, cut…) at both [ends],
/// printed in the type face at 13 px on a 20 px line. [children]
/// ([ReceiptHeader], [ReceiptLines], [ReceiptTotal], [ReceiptDivider],
/// [ReceiptBarcode], [ReceiptFooter]) stack 12 px apart on a centred
/// column [width] wide, padded 20 × 32 px.
///
/// Give it a [semanticLabel] (like `Receipt from Looseleaf Cafe`) to make
/// it a named, self-contained document for screen readers.
///
/// ```dart
/// const Receipt(
///   semanticLabel: 'Receipt from Looseleaf Cafe',
///   children: [
///     ReceiptHeader(children: [Text('Looseleaf Cafe'), Text('25 sep 2026')]),
///     ReceiptLines(children: [
///       ReceiptLine(qty: 1, price: Text('4.50'), child: Text('oat latte')),
///     ]),
///     ReceiptTotal(circled: ReceiptPen.redfelt, child: Text('4.50')),
///     ReceiptBarcode(value: '0042 1187'),
///     ReceiptFooter(Text('thank you - come again')),
///   ],
/// )
/// ```
///
/// Mirrors `Receipt` in upstream `src/components/ui/receipt.tsx`.
class Receipt extends StatelessWidget {
  const Receipt({
    super.key,
    this.ends = EdgeKind.zig,
    this.width = defaultWidth,
    this.tilt = true,
    this.tiltDegrees,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.curl = false,
    this.seed,
    this.semanticLabel,
    this.children = const [],
  });

  /// Upstream's `w-72`.
  static const double defaultWidth = 288;

  /// The cut of both ends: the tear bar's sawtooth by default.
  final EdgeKind ends;

  /// The paper's width.
  final double width;

  /// False lays the receipt flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded within the receipt stock's when null.
  final double? tiltDegrees;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// The tape the strips are cut from.
  final TapeKind tapeKind;

  /// A clip, pin, staple or binder clip; none when null.
  final FastenerKind? fastener;

  /// The fastener's colour.
  final Accent? fastenerTone;

  /// The shadow.
  final PaperShadow shadow;

  /// A curled bottom-right corner.
  final bool curl;

  /// Pins the paper, its ends and its tilt.
  final String? seed;

  /// Names the receipt as a document, like `aria-label` on an `article`.
  final String? semanticLabel;

  /// The parts.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final receipt = SizedBox(
      width: width,
      child: Paper(
        stock: StockName.receipt,
        rules: RuleName.none,
        edge: EdgeSpec(top: ends, bottom: ends),
        tilt: tilt,
        tiltDegrees: tiltDegrees,
        tape: tape,
        tapeKind: tapeKind,
        fastener: fastener,
        fastenerTone: fastenerTone,
        shadow: shadow,
        curl: curl,
        seed: seed,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d20,
          vertical: Spacing.d32,
        ),
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.type,
            cssSize: 13,
            cssLineHeight: 20 / 13,
            color: theme.colors.ink,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: children,
          ),
        ),
      ),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: Center(widthFactor: 1, heightFactor: 1, child: receipt),
    );
  }
}
