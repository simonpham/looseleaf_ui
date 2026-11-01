import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/tape/tape.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A sheet of paper with [child] on it: any stock (paper, slip, index card,
/// graph, dot grid, guest check, ledger, order pad, kraft, napkin, five
/// sticky notes, photo, parchment, receipt), any edge per side, its shadow,
/// printed rules and a small seeded tilt, optionally taped down, clipped,
/// pinned or stapled, with a curled corner.
///
/// The paper sizes to [child] plus [padding]; give it a size from outside
/// (`SizedBox`) for an empty sheet. Only the sheet tilts; the content stays
/// upright. Calm density hides tape and fasteners.
///
/// This is the surface every paper component sits on: cards, dialogs,
/// sheets, popovers, menus and tooltips are a [Paper] with their own stock
/// and padding.
///
/// ```dart
/// Paper(
///   stock: StockName.indexCard,
///   fastener: FastenerKind.pin,
///   padding: const EdgeInsets.all(Spacing.d20),
///   child: const Text('Pinned'),
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/paper.tsx`.
class Paper extends StatefulWidget {
  const Paper({
    super.key,
    this.stock = StockName.paper,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.rules,
    this.rulesOffset,
    this.mirrorRules = false,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.curl = false,
    this.seed,
    this.padding = EdgeInsets.zero,
    this.decor,
    this.child,
  });

  /// The paper stock.
  final StockName stock;

  /// The edge of each side; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the sheet flat.
  final bool tilt;

  /// A fixed tilt in degrees (upstream's numeric `tilt`); seeded when null.
  final double? tiltDegrees;

  /// The printed rules; the stock's when null.
  final RuleName? rules;

  /// `--ll-rule-offset` in px: how far rules sit above the text baseline.
  final double? rulesOffset;

  /// Flips the rules, for right-to-left pages.
  final bool mirrorRules;

  /// Tape strips across the corners or the top; none when null.
  final PaperTape? tape;

  /// The tape the strips are cut from.
  final TapeKind tapeKind;

  /// A clip, pin, staple or binder clip; none when null.
  final FastenerKind? fastener;

  /// The fastener's colour; steel (clip) or tomato (pin) when null.
  final Accent? fastenerTone;

  /// The shadow.
  final PaperShadow shadow;

  /// A curled bottom-right corner.
  final bool curl;

  /// Pins the outline, tooth, tilt, tape and fastener.
  final String? seed;

  /// Space between the sheet's edge and [child].
  final EdgeInsetsGeometry padding;

  /// Drawn decor filling the whole sheet over the paper and under [child]
  /// (a page's punched holes, a coffee ring); decorative.
  final Widget? decor;

  /// What is written on the sheet.
  final Widget? child;

  @override
  State<Paper> createState() => _PaperState();
}

class _PaperState extends State<Paper> with InkSeed {
  static const double _tapeLength = 64;
  static const double _tapeHeight = 20;

  List<Widget> _tapes(String seed) {
    final places = switch (widget.tape) {
      null => const <(double?, double?, double?, double)>[],
      PaperTape.corner => const [(-Spacing.d8, -Spacing.d28, null, -38.0)],
      PaperTape.top => const [(-Spacing.d12, null, null, -2.0)],
      PaperTape.both => const [
        (-Spacing.d8, -Spacing.d28, null, -38.0),
        (-Spacing.d8, null, -Spacing.d28, 36.0),
      ],
    };
    return [
      for (final (i, (top, left, right, angle)) in places.indexed)
        _place(
          top: top ?? 0,
          left: left,
          right: right,
          child: Tape(
            kind: widget.tapeKind,
            length: _tapeLength,
            height: _tapeHeight,
            angle: angle,
            seed: '$seed:tape:$i',
          ),
        ),
    ];
  }

  Widget? _fastener(String seed) {
    final kind = widget.fastener;
    if (kind == null) return null;
    final fastener = PaperFastener(
      kind: kind,
      tone: widget.fastenerTone,
      seed: '$seed:fastener',
    );
    return switch (kind) {
      FastenerKind.clip => _place(
        top: -Spacing.d20,
        right: Spacing.d32,
        child: fastener,
      ),
      FastenerKind.pin => _place(top: -Spacing.d8, child: fastener),
      FastenerKind.staple => _place(
        top: Spacing.d8,
        left: Spacing.d8,
        child: fastener,
      ),
      FastenerKind.binderClip => _place(top: -Spacing.d40, child: fastener),
    };
  }

  static Widget _place({
    required double top,
    double? left,
    double? right,
    required Widget child,
  }) {
    if (left == null && right == null) {
      return Positioned(
        top: top,
        left: 0,
        right: 0,
        child: Center(child: child),
      );
    }
    return Positioned(top: top, left: left, right: right, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final seed = inkSeed(widget.seed);
    final calm = PaperInk.calm(LooseleafTheme.of(context));
    final fastener = _fastener(seed);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: PaperBackground(
            seed: seed,
            stock: widget.stock,
            edge: widget.edge,
            shadow: widget.shadow,
            tilt: widget.tilt,
            tiltDegrees: widget.tiltDegrees,
            rules: widget.rules,
            rulesOffset: widget.rulesOffset,
            mirrorRules: widget.mirrorRules,
            curl: widget.curl,
          ),
        ),
        if (widget.decor case final decor?)
          Positioned.fill(
            child: ExcludeSemantics(child: IgnorePointer(child: decor)),
          ),
        Padding(
          padding: widget.padding,
          child: widget.child ?? const SizedBox.shrink(),
        ),
        if (!calm) ..._tapes(seed),
        if (!calm && fastener != null) fastener,
      ],
    );
  }
}
