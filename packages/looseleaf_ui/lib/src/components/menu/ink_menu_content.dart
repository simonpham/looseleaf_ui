import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Tells an [InkMenuContent] where its slip landed.
class InkMenuPositionScope extends InheritedWidget {
  const InkMenuPositionScope({
    super.key,
    required this.position,
    required super.child,
  });

  /// The slip's position, null before the first layout.
  final OverlayPosition? position;

  /// The nearest position, or null.
  static OverlayPosition? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InkMenuPositionScope>()
      ?.position;

  @override
  bool updateShouldNotify(InkMenuPositionScope oldWidget) =>
      oldWidget.position != position;
}

/// A menu's slip: the rows ([InkMenuItem], [InkMenuCheckboxItem],
/// [InkMenuRadioGroup], [InkMenuLabel], [InkMenuSeparator], [InkMenuSub],
/// …) on a [Paper] (slip by default, any stock, edge, tilt or tape),
/// scrolling inside when the window is short.
///
/// The placement props override the menu kind's (a dropdown's 6 px under
/// its button, a context menu's pointer, a menubar's start-aligned menus).
/// [width] fixes the width (upstream's `w-56`), otherwise it is the widest
/// row's, at least 128 px (192 in a menubar).
///
/// Mirrors the `*MenuContent` parts of upstream `dropdown-menu.tsx`,
/// `context-menu.tsx` and `menubar.tsx`.
class InkMenuContent extends StatefulWidget {
  const InkMenuContent({
    super.key,
    required this.children,
    this.side,
    this.align,
    this.sideOffset,
    this.alignOffset,
    this.collisionPadding = Spacing.d8,
    this.avoidCollisions = true,
    this.loop = false,
    this.stock = StockName.slip,
    this.edge,
    this.tilt = true,
    this.tape,
    this.width,
    this.minWidth,
    this.seed,
    this.semanticLabel,
  });

  /// The rows.
  final List<Widget> children;

  /// The side of the trigger it opens on.
  final OverlaySide? side;

  /// How it lines up with the trigger.
  final OverlayAlign? align;

  /// The gap to the trigger.
  final double? sideOffset;

  /// A shift along the side.
  final double? alignOffset;

  /// How far it keeps from the window's edges.
  final double collisionPadding;

  /// Flip and slide to stay in the window.
  final bool avoidCollisions;

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

  /// The least width; the menu kind's when null.
  final double? minWidth;

  /// Pins the paper.
  final String? seed;

  /// Names the menu for screen readers.
  final String? semanticLabel;

  @override
  State<InkMenuContent> createState() => _InkMenuContentState();
}

class _InkMenuContentState extends State<InkMenuContent> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final root = InkMenuRootScope.maybeOf(context);
    final placement = root?.placement ?? const InkMenuPlacement();
    return InkMenuPanel(
      seed: inkSeed(widget.seed),
      stock: widget.stock,
      edge: widget.edge,
      tilt: widget.tilt,
      tape: widget.tape,
      width: widget.width,
      minWidth:
          widget.minWidth ?? placement.minWidth ?? InkMenuMetrics.minWidth,
      loop: widget.loop,
      focusFirst: root?.focusFirst ?? false,
      position: InkMenuPositionScope.maybeOf(context),
      side: widget.side ?? placement.side,
      semanticLabel: widget.semanticLabel,
      children: widget.children,
    );
  }
}
