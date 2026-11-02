import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The paper a popup is written on: a [Paper] (slip by default, no rules)
/// lifted off the page with the `lift` shadow (a hairline when calm), in
/// ink, optionally with a hand-drawn [pointer] at its anchor.
///
/// [position] is what [AnchoredOverlay] reports: its side turns the pointer
/// and its anchor centre places it. [width] fixes the width (a popover's
/// `w-72`); [maxWidth] caps it.
///
/// Every overlay component writes on this: popover, hover card, menus,
/// select, command, tooltip (with its own stock and shadow).
///
/// Mirrors the `Paper` of upstream `PopoverContent` and the `SLIP` classes
/// of `src/lib/menu-styles.ts`.
class PaperPopup extends StatelessWidget {
  const PaperPopup({
    super.key,
    required this.seed,
    required this.child,
    this.stock = StockName.slip,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.shadow,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.padding = EdgeInsets.zero,
    this.width,
    this.maxWidth = double.infinity,
    this.position,
    this.side = OverlaySide.bottom,
    this.pointer,
  });

  /// Seeds the sheet and the pointer.
  final String seed;

  /// The popup's content.
  final Widget child;

  /// The paper stock.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the popup flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded when null.
  final double? tiltDegrees;

  /// The shadow; `lift` (a hairline when calm) when null.
  final PaperShadow? shadow;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// The tape the strips are cut from.
  final TapeKind tapeKind;

  /// A fastener (a popover's pin); none when null.
  final FastenerKind? fastener;

  /// The fastener's colour.
  final Accent? fastenerTone;

  /// The padding around [child].
  final EdgeInsetsGeometry padding;

  /// A fixed width, the content's when null.
  final double? width;

  /// The largest width.
  final double maxWidth;

  /// Where the popup landed, for the pointer.
  final OverlayPosition? position;

  /// The side to assume until [position] is known.
  final OverlaySide side;

  /// The pointer's size; no pointer when null.
  final Size? pointer;

  /// Whether [context] sits on a popup's paper, where a nested sheet (a
  /// [Command]'s) puts its own paper away, like upstream's `NESTED` rule.
  static bool isAround(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_PaperPopupScope>() != null;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final calm = PaperInk.calm(theme);
    final sheet = Paper(
      stock: stock,
      edge: edge,
      tilt: tilt,
      tiltDegrees: tiltDegrees,
      rules: RuleName.none,
      tape: tape,
      tapeKind: tapeKind,
      fastener: fastener,
      fastenerTone: fastenerTone,
      shadow:
          shadow ??
          switch (calm) {
            true => PaperShadow.hair,
            false => PaperShadow.lift,
          },
      seed: seed,
      padding: padding,
      child: DefaultTextStyle.merge(
        style: theme.typography.interface(color: theme.colors.ink),
        child: _PaperPopupScope(child: child),
      ),
    );
    final sized = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width ?? 0,
        maxWidth: switch (width) {
          final fixed? => fixed.clamp(0, maxWidth),
          null => maxWidth,
        },
      ),
      child: sheet,
    );
    final size = pointer;
    if (size == null) return sized;
    final placed = position?.side ?? side;
    final arrow = PopupPointer(side: placed, seed: seed, size: size);
    final reach = size.height;
    final rail = CustomSingleChildLayout(
      delegate: _PointerRail(side: placed, center: position?.anchorCenter),
      child: arrow,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        sized,
        switch (placed) {
          OverlaySide.bottom => Positioned(
            left: 0,
            right: 0,
            top: -reach,
            height: reach,
            child: rail,
          ),
          OverlaySide.top => Positioned(
            left: 0,
            right: 0,
            bottom: -reach,
            height: reach,
            child: rail,
          ),
          OverlaySide.right => Positioned(
            top: 0,
            bottom: 0,
            left: -reach,
            width: reach,
            child: rail,
          ),
          OverlaySide.left => Positioned(
            top: 0,
            bottom: 0,
            right: -reach,
            width: reach,
            child: rail,
          ),
        },
      ],
    );
  }
}

class _PaperPopupScope extends InheritedWidget {
  const _PaperPopupScope({required super.child});

  @override
  bool updateShouldNotify(_PaperPopupScope oldWidget) => false;
}

class _PointerRail extends SingleChildLayoutDelegate {
  _PointerRail({required this.side, required this.center});

  final OverlaySide side;
  final double? center;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      const BoxConstraints();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final along = switch (side.vertical) {
      true => size.width,
      false => size.height,
    };
    final half = switch (side.vertical) {
      true => childSize.width / 2,
      false => childSize.height / 2,
    };
    final low = half + Spacing.d4;
    final high = along - half - Spacing.d4;
    final mid = switch (high > low) {
      true => (center ?? along / 2).clamp(low, high),
      false => along / 2,
    };
    return switch (side.vertical) {
      true => Offset(mid - half, 0),
      false => Offset(0, mid - half),
    };
  }

  @override
  bool shouldRelayout(_PointerRail oldDelegate) =>
      oldDelegate.side != side || oldDelegate.center != center;
}
