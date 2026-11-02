import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Tells a [PopoverContent] where its popup landed.
class PopoverContentScope extends InheritedWidget {
  const PopoverContentScope({
    super.key,
    required this.position,
    required super.child,
  });

  /// The popup's position, null before the first layout.
  final OverlayPosition? position;

  @override
  bool updateShouldNotify(PopoverContentScope oldWidget) =>
      oldWidget.position != position;
}

/// A popover's note: a slip of paper (any stock, edge, tilt, tape or a
/// push-pin) 288 px wide with 16 px padding (14 compact, 12 calm), lifted
/// with the `lift` shadow, optionally with a hand-drawn arrow at the
/// trigger. It also says where it goes: [side] (below by default), [align],
/// [sideOffset] 8 px away, staying [collisionPadding] inside the window.
///
/// Mirrors `PopoverContent` in upstream `src/components/ui/popover.tsx`.
class PopoverContent extends StatefulWidget {
  const PopoverContent({
    super.key,
    required this.child,
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.center,
    this.sideOffset = Spacing.d8,
    this.alignOffset = 0,
    this.collisionPadding = Spacing.d8,
    this.avoidCollisions = true,
    this.stock = StockName.slip,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.pin = false,
    this.pinTone,
    this.tape,
    this.arrow = false,
    this.width = defaultWidth,
    this.padding,
    this.seed,
    this.semanticLabel,
  });

  /// Upstream's `w-72`.
  static const double defaultWidth = 288;

  /// The note's content.
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

  /// A fixed tilt in degrees.
  final double? tiltDegrees;

  /// A push-pin through the top.
  final bool pin;

  /// The pin's colour; tomato when null.
  final Accent? pinTone;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// A hand-drawn arrow pointing at the trigger.
  final bool arrow;

  /// The width; the content's when null.
  final double? width;

  /// The padding; 16 / 14 / 12 by density when null.
  final EdgeInsetsGeometry? padding;

  /// Pins the paper and the arrow.
  final String? seed;

  /// Names the popover for screen readers.
  final String? semanticLabel;

  /// How far the arrow reaches out, added to [sideOffset].
  double get pointerReach => switch (arrow) {
    true => PopupPointer.popoverSize.height,
    false => 0,
  };

  @override
  State<PopoverContent> createState() => _PopoverContentState();
}

class _PopoverContentState extends State<PopoverContent> with InkSeed {
  static const ByDensity<double> _padding = ByDensity(
    comfortable: Spacing.d16,
    compact: Spacing.d14,
    calm: Spacing.d12,
  );

  @override
  Widget build(BuildContext context) {
    final position = context
        .dependOnInheritedWidgetOfExactType<PopoverContentScope>()
        ?.position;
    final window = MediaQuery.maybeSizeOf(context)?.width ?? double.infinity;
    return PopupFit(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        scopesRoute: true,
        namesRoute: widget.semanticLabel != null,
        label: widget.semanticLabel,
        child: PaperPopup(
          seed: inkSeed(widget.seed),
          stock: widget.stock,
          edge: widget.edge,
          tilt: widget.tilt,
          tiltDegrees: widget.tiltDegrees,
          tape: widget.tape,
          fastener: switch (widget.pin) {
            true => FastenerKind.pin,
            false => null,
          },
          fastenerTone: widget.pinTone,
          padding: widget.padding ?? EdgeInsets.all(_padding.of(context)),
          width: widget.width,
          maxWidth: window - Spacing.d16,
          position: position,
          side: widget.side,
          pointer: switch (widget.arrow) {
            true => PopupPointer.popoverSize,
            false => null,
          },
          child: widget.child,
        ),
      ),
    );
  }
}
