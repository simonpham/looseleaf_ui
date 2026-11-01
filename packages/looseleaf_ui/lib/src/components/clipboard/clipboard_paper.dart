import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/clipboard/clipboard_scope.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sheet on a clipboard: a [Paper] with ruled lines and a red margin by
/// default, at least 256 px tall, its text starting 56 px in (past the
/// margin) and 72 px down (under the clip). It grows into a clipboard
/// given a least height. The rules mirror right to left.
///
/// Mirrors `ClipboardPaper` in upstream `src/components/ui/clipboard.tsx`.
class ClipboardPaper extends StatelessWidget {
  const ClipboardPaper({
    super.key,
    this.stock = StockName.paper,
    this.rules = RuleName.ruled,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.minHeight = defaultMinHeight,
    this.padding = defaultPadding,
    this.seed,
    required this.child,
  });

  /// Upstream's `min-h-64`.
  static const double defaultMinHeight = 256;

  /// Upstream's `pt-18 pe-5 pb-5 ps-14`.
  static const EdgeInsetsDirectional defaultPadding =
      EdgeInsetsDirectional.fromSTEB(
        Spacing.d56,
        Spacing.d36 * 2,
        Spacing.d20,
        Spacing.d20,
      );

  /// The paper stock.
  final StockName stock;

  /// The printed rules.
  final RuleName rules;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the sheet flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded when null.
  final double? tiltDegrees;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// The tape the strips are cut from.
  final TapeKind tapeKind;

  /// The sheet's least height.
  final double minHeight;

  /// Space between the sheet's edge and [child].
  final EdgeInsetsGeometry padding;

  /// Pins the sheet.
  final String? seed;

  /// What is written on the sheet: notes, a checklist, a form.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final paper = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Paper(
        stock: stock,
        rules: rules,
        mirrorRules: Directionality.of(context) == TextDirection.rtl,
        edge: edge,
        tilt: tilt,
        tiltDegrees: tiltDegrees,
        tape: tape,
        tapeKind: tapeKind,
        seed: seed,
        padding: padding,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: theme.colors.ink),
          child: Align(alignment: AlignmentDirectional.topStart, child: child),
        ),
      ),
    );
    if (!ClipboardScope.fillsOf(context)) return paper;
    return Expanded(child: paper);
  }
}
