import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';

/// A sub-menu's own slip, set down beside the row that opens it with its
/// first row level with that row ([alignOffset] -4, the slip's padding).
/// Takes the same paper props as [InkMenuContent].
///
/// Mirrors the `*MenuSubContent` parts of upstream `dropdown-menu.tsx`,
/// `context-menu.tsx` and `menubar.tsx`.
class InkMenuSubContent extends StatefulWidget {
  const InkMenuSubContent({
    super.key,
    required this.children,
    this.sideOffset = 0,
    this.alignOffset = InkMenuMetrics.subAlignOffset,
    this.loop = false,
    this.stock = StockName.slip,
    this.edge,
    this.tilt = true,
    this.tape,
    this.width,
    this.minWidth = InkMenuMetrics.minWidth,
    this.seed,
    this.semanticLabel,
  });

  /// The rows.
  final List<Widget> children;

  /// The gap to the opening row.
  final double sideOffset;

  /// A shift along the side.
  final double alignOffset;

  /// Whether Up and Down wrap at the ends.
  final bool loop;

  /// The paper stock.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the slip flat.
  final bool tilt;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// A fixed width; the widest row's when null.
  final double? width;

  /// The least width.
  final double minWidth;

  /// Pins the paper.
  final String? seed;

  /// Names the sub-menu for screen readers.
  final String? semanticLabel;

  @override
  State<InkMenuSubContent> createState() => _InkMenuSubContentState();
}

class _InkMenuSubContentState extends State<InkMenuSubContent> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final sub = InkMenuSubScope.of(context);
    return InkMenuPanel(
      seed: inkSeed(widget.seed),
      stock: widget.stock,
      edge: widget.edge,
      tilt: widget.tilt,
      tape: widget.tape,
      width: widget.width,
      minWidth: widget.minWidth,
      loop: widget.loop,
      focusFirst: sub.focusFirstOnOpen,
      position: InkMenuPositionScope.maybeOf(context),
      side: sub.side,
      sub: sub,
      semanticLabel: widget.semanticLabel,
      children: widget.children,
    );
  }
}
