import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Tells a [TooltipContent] where its popup landed.
class TooltipContentScope extends InheritedWidget {
  const TooltipContentScope({
    super.key,
    required this.position,
    required super.child,
  });

  /// The popup's position, null before the first layout.
  final OverlayPosition? position;

  @override
  bool updateShouldNotify(TooltipContentScope oldWidget) =>
      oldWidget.position != position;
}

/// A tooltip's note: a small sticky note (yellow by default) with a seeded
/// tilt and its own shadow, 10 × 6 px padding, small snug text, at most
/// 352 px wide, with a hand-drawn arrow at the trigger. It also says where
/// it goes: [side] (above by default), [align], [sideOffset] 1 px away.
///
/// Mirrors `TooltipContent` in upstream `src/components/ui/tooltip.tsx`.
class TooltipContent extends StatefulWidget {
  const TooltipContent({
    super.key,
    required this.child,
    this.side = OverlaySide.top,
    this.align = OverlayAlign.center,
    this.sideOffset = Spacing.d1,
    this.alignOffset = 0,
    this.collisionPadding = Spacing.d8,
    this.avoidCollisions = true,
    this.stock = StockName.stickyYellow,
    this.tilt = true,
    this.tiltDegrees,
    this.arrow = true,
    this.maxWidth = defaultMaxWidth,
    this.seed,
    this.semanticLabel,
  });

  /// Upstream's `max-w-[22rem]`.
  static const double defaultMaxWidth = 352;

  /// The note.
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

  /// False lays it flat.
  final bool tilt;

  /// A fixed tilt in degrees.
  final double? tiltDegrees;

  /// A hand-drawn arrow pointing at the trigger.
  final bool arrow;

  /// The largest width.
  final double maxWidth;

  /// Pins the paper and the arrow.
  final String? seed;

  /// What the trigger is described as; [child]'s text when it is a [Text].
  final String? semanticLabel;

  /// How far the arrow reaches out, added to [sideOffset].
  double get pointerReach => switch (arrow) {
    true => PopupPointer.tooltipSize.height,
    false => 0,
  };

  /// The description the trigger carries for screen readers.
  String? get description =>
      semanticLabel ??
      switch (child) {
        final Text text => text.data,
        _ => null,
      };

  @override
  State<TooltipContent> createState() => _TooltipContentState();
}

class _TooltipContentState extends State<TooltipContent> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final position = context
        .dependOnInheritedWidgetOfExactType<TooltipContentScope>()
        ?.position;
    final window = MediaQuery.maybeSizeOf(context)?.width ?? double.infinity;
    return PaperPopup(
      seed: inkSeed(widget.seed),
      stock: widget.stock,
      tilt: widget.tilt,
      tiltDegrees: widget.tiltDegrees,
      shadow: PaperShadow.stock,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.d10,
        vertical: Spacing.d6,
      ),
      maxWidth: switch (window - Spacing.d16 < widget.maxWidth) {
        true => window - Spacing.d16,
        false => widget.maxWidth,
      },
      position: position,
      side: widget.side,
      pointer: switch (widget.arrow) {
        true => PopupPointer.tooltipSize,
        false => null,
      },
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 14,
          cssLineHeight: 1.375,
          color: theme.colors.ink,
        ),
        textWidthBasis: TextWidthBasis.longestLine,
        child: widget.child,
      ),
    );
  }
}
