import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Tells a [HoverCardContent] where its popup landed.
class HoverCardContentScope extends InheritedWidget {
  const HoverCardContentScope({
    super.key,
    required this.position,
    required super.child,
  });

  /// The popup's position, null before the first layout.
  final OverlayPosition? position;

  @override
  bool updateShouldNotify(HoverCardContentScope oldWidget) =>
      oldWidget.position != position;
}

/// A hover card's polaroid: a photo-stock print 256 px wide, 10 px of
/// margin with a deeper 16 px chin (8 px all round when compact or calm),
/// tilted and lifted. Usually a [HoverCardMedia], a [HoverCardCaption] and
/// a line of text. It also says where it goes: [side] (below by default),
/// [align], [sideOffset] 8 px away, staying [collisionPadding] inside.
///
/// Mirrors `HoverCardContent` in upstream `src/components/ui/hover-card.tsx`.
class HoverCardContent extends StatefulWidget {
  const HoverCardContent({
    super.key,
    required this.child,
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.center,
    this.sideOffset = Spacing.d8,
    this.alignOffset = 0,
    this.collisionPadding = Spacing.d8,
    this.avoidCollisions = true,
    this.stock = StockName.photo,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.tape,
    this.width = defaultWidth,
    this.padding,
    this.seed,
    this.semanticLabel,
  });

  /// Upstream's `w-64`.
  static const double defaultWidth = Spacing.d256;

  /// The card's content.
  final Widget child;

  /// The side of the trigger it opens on.
  final OverlaySide side;

  /// How it lines up with the trigger.
  final OverlayAlign align;

  /// The gap to the trigger.
  final double sideOffset;

  /// A shift along the side.
  final double alignOffset;

  /// How far it keeps from the window's edges.
  final double collisionPadding;

  /// Flip and slide to stay in the window.
  final bool avoidCollisions;

  /// The paper stock.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays it flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded when null.
  final double? tiltDegrees;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// The width; the content's when null.
  final double? width;

  /// The margin; the polaroid's by density when null.
  final EdgeInsetsGeometry? padding;

  /// Pins the print.
  final String? seed;

  /// Names the card for screen readers.
  final String? semanticLabel;

  @override
  State<HoverCardContent> createState() => _HoverCardContentState();
}

class _HoverCardContentState extends State<HoverCardContent> with InkSeed {
  static const ByDensity<EdgeInsets> _padding = ByDensity(
    comfortable: EdgeInsets.fromLTRB(
      Spacing.d10,
      Spacing.d10,
      Spacing.d10,
      Spacing.d16,
    ),
    compact: EdgeInsets.all(Spacing.d8),
    calm: EdgeInsets.all(Spacing.d8),
  );

  @override
  Widget build(BuildContext context) {
    final position = context
        .dependOnInheritedWidgetOfExactType<HoverCardContentScope>()
        ?.position;
    final window = MediaQuery.maybeSizeOf(context)?.width ?? double.infinity;
    return PopupFit(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: widget.semanticLabel,
        child: PaperPopup(
          seed: inkSeed(widget.seed),
          stock: widget.stock,
          edge: widget.edge,
          tilt: widget.tilt,
          tiltDegrees: widget.tiltDegrees,
          tape: widget.tape,
          padding: widget.padding ?? _padding.of(context),
          width: widget.width,
          maxWidth: window - Spacing.d16,
          position: position,
          side: widget.side,
          child: widget.child,
        ),
      ),
    );
  }
}
