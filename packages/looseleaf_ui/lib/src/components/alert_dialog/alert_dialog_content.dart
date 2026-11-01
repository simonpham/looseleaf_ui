import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/alert_dialog/alert_dialog.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/tape/tape.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An alert dialog's sheet: a [DialogContent] without the close mark, up
/// to 512 px wide ([AlertDialogSize.small]: 320), with its [children]
/// 16 px apart. [AlertDialogTone.danger] tapes the top corners down with
/// tomato hazard washi (not on phones or when calm).
///
/// Mirrors `AlertDialogContent` in upstream
/// `src/components/ui/alert-dialog.tsx`.
class AlertDialogContent extends StatefulWidget {
  const AlertDialogContent({
    super.key,
    required this.children,
    this.size = AlertDialogSize.regular,
    this.tone = AlertDialogTone.neutral,
    this.stock = StockName.paper,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.seed,
    this.semanticLabel,
  });

  /// Usually an [AlertDialogHeader] and an [AlertDialogFooter].
  final List<Widget> children;

  /// How wide it gets and how its parts line up.
  final AlertDialogSize size;

  /// [AlertDialogTone.danger] adds the hazard tape.
  final AlertDialogTone tone;

  /// The paper stock.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the sheet flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded when null.
  final double? tiltDegrees;

  /// Pins the sheet and the tape.
  final String? seed;

  /// Names it for screen readers when it has no title.
  final String? semanticLabel;

  /// The small size's widest: `max-w-xs`.
  static const double smallWidth = 320;

  @override
  State<AlertDialogContent> createState() => _AlertDialogContentState();
}

class _AlertDialogContentState extends State<AlertDialogContent> with InkSeed {
  static const double _tapeLength = 68;
  static const double _tapeHeight = 20;

  List<Widget> _hazard(String seed) => [
    Positioned(
      top: -Spacing.d8,
      left: -Spacing.d28,
      child: Tape(
        kind: TapeKind.washiStripes,
        color: Accent.tomato,
        length: _tapeLength,
        height: _tapeHeight,
        angle: -38,
        seed: '$seed:hz-a',
      ),
    ),
    Positioned(
      top: -Spacing.d8,
      right: -Spacing.d28,
      child: Tape(
        kind: TapeKind.washiStripes,
        color: Accent.tomato,
        length: _tapeLength,
        height: _tapeHeight,
        angle: 36,
        seed: '$seed:hz-b',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final seed = inkSeed(widget.seed);
    final calm = PaperInk.calm(LooseleafTheme.of(context));
    final taped = widget.tone == AlertDialogTone.danger && !calm;
    return AlertDialogContentScope(
      size: widget.size,
      child: Semantics(
        explicitChildNodes: true,
        child: DialogContent(
          showCloseButton: false,
          stock: widget.stock,
          edge: widget.edge,
          tilt: widget.tilt,
          tiltDegrees: widget.tiltDegrees,
          seed: seed,
          semanticLabel: widget.semanticLabel,
          maxWidth: switch (widget.size) {
            AlertDialogSize.regular => DialogMetrics.maxWidth,
            AlertDialogSize.small => AlertDialogContent.smallWidth,
          },
          decor: [if (taped) ..._hazard(seed)],
          children: widget.children,
        ),
      ),
    );
  }
}
