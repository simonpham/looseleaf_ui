import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/sheet/sheet.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The page a [Sheet] slides in: flat [Paper] along a window edge
/// ([side]), bound along its inner edge ([binding]: a wire spiral or
/// punched holes in a 28 px strip, or a perforated or torn edge), casting
/// its shadow onto the page, with the doodled × in the corner.
///
/// Left and right sheets are full height and three quarters of the window
/// wide (at most 384 px from 640 px up); top and bottom ones are full
/// width and at most 85 % of the window tall. The [children] stack 16 px
/// apart with no padding of their own: [SheetHeader] and [SheetFooter]
/// bring theirs, and a footer in a side sheet sits at the bottom.
///
/// Mirrors `SheetContent` in upstream `src/components/ui/sheet.tsx`.
class SheetContent extends StatefulWidget {
  const SheetContent({
    super.key,
    required this.children,
    this.side = OverlaySide.right,
    this.showCloseButton = true,
    this.binding = SheetBinding.spiral,
    this.stock = StockName.paper,
    this.rules = RuleName.none,
    this.width,
    this.seed,
    this.semanticLabel,
  });

  /// The header, the content and the footer, top to bottom.
  final List<Widget> children;

  /// The window edge it slides in from.
  final OverlaySide side;

  /// The doodled × in the corner.
  final bool showCloseButton;

  /// How the inner edge is bound.
  final SheetBinding binding;

  /// The paper stock.
  final StockName stock;

  /// The printed rules; none by default.
  final RuleName rules;

  /// A fixed width for a left or right sheet.
  final double? width;

  /// Pins the paper, the binding and the close mark.
  final String? seed;

  /// Names the sheet for screen readers when it has no title.
  final String? semanticLabel;

  /// A side sheet's widest from 640 px: `sm:max-w-sm`.
  static const double maxSideWidth = 384;

  /// A side sheet's share of the window: `w-3/4`.
  static const double sideShare = 0.75;

  /// A top or bottom sheet's tallest share: `max-h-[85dvh]`.
  static const double edgeShare = 0.85;

  /// The binding strip: `w-7` / `h-7`.
  static const double bindingSize = Spacing.d28;

  /// The page's padding on the bound edge: `pl-6` etc.
  static const double boundPadding = Spacing.d24;

  /// The close mark's inset from a bound edge: `end-9` / `top-9`.
  static const double boundCloseInset = Spacing.d36;

  @override
  State<SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<SheetContent> with InkSeed {
  OverlaySide get _inner => switch (widget.side) {
    OverlaySide.right => OverlaySide.left,
    OverlaySide.left => OverlaySide.right,
    OverlaySide.top => OverlaySide.bottom,
    OverlaySide.bottom => OverlaySide.top,
  };

  bool get _bound =>
      widget.binding == SheetBinding.spiral ||
      widget.binding == SheetBinding.holes;

  EdgeSpec? get _edge {
    final kind = switch (widget.binding) {
      SheetBinding.perf => EdgeKind.perf,
      SheetBinding.torn => EdgeKind.torn,
      _ => null,
    };
    if (kind == null) return null;
    return switch (_inner) {
      OverlaySide.left => EdgeSpec(left: kind),
      OverlaySide.right => EdgeSpec(right: kind),
      OverlaySide.top => EdgeSpec(top: kind),
      OverlaySide.bottom => EdgeSpec(bottom: kind),
    };
  }

  EdgeInsets _padding(double safeBottom) {
    final bound = switch (_bound) {
      true => SheetContent.boundPadding,
      false => 0.0,
    };
    final bottom = switch (widget.side) {
      OverlaySide.top => 0.0,
      _ => safeBottom,
    };
    return switch (_inner) {
      OverlaySide.left => EdgeInsets.only(left: bound, bottom: bottom),
      OverlaySide.right => EdgeInsets.only(right: bound, bottom: bottom),
      OverlaySide.top => EdgeInsets.only(top: bound, bottom: bottom),
      OverlaySide.bottom => EdgeInsets.only(bottom: bound + bottom),
    };
  }

  List<BoxShadow> _shadow(LooseleafThemeData theme) {
    final k = theme.shadowK;
    Color shade(double alpha) =>
        theme.colors.shade.withValues(alpha: (alpha * k).clamp(0.0, 1.0));
    final (dx, dy) = switch (widget.side) {
      OverlaySide.right => (-1.0, 0.0),
      OverlaySide.left => (1.0, 0.0),
      OverlaySide.top => (0.0, 1.0),
      OverlaySide.bottom => (0.0, -1.0),
    };
    return [
      BoxShadow(
        color: shade(0.34),
        offset: Offset(dx * 7, dy * 7),
        blurRadius: 18,
        spreadRadius: -6,
      ),
      BoxShadow(
        color: shade(0.24),
        offset: Offset(dx, dy),
        blurRadius: 1.5,
      ),
    ];
  }

  Widget _binding(String seed) {
    final params = SheetBindingParams(
      edge: switch (_inner) {
        OverlaySide.left => BindingEdge.left,
        OverlaySide.right => BindingEdge.right,
        OverlaySide.top => BindingEdge.top,
        OverlaySide.bottom => BindingEdge.bottom,
      },
      kind: switch (widget.binding) {
        SheetBinding.holes => BindingKind.holes,
        _ => BindingKind.spiral,
      },
    );
    final strip = IgnorePointer(
      child: ExcludeSemantics(
        child: InkSurface(
          source: RecipeInkSource(
            sheetBindingRecipe,
            params,
            json: params.toJson(),
          ),
          seed: '$seed|bind',
        ),
      ),
    );
    const size = SheetContent.bindingSize;
    return switch (_inner) {
      OverlaySide.left => Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        width: size,
        child: strip,
      ),
      OverlaySide.right => Positioned(
        top: 0,
        bottom: 0,
        right: 0,
        width: size,
        child: strip,
      ),
      OverlaySide.top => Positioned(
        left: 0,
        right: 0,
        top: 0,
        height: size,
        child: strip,
      ),
      OverlaySide.bottom => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        height: size,
        child: strip,
      ),
    };
  }

  Widget _closeMark(String seed, TextDirection direction) {
    final endSide = switch (direction) {
      TextDirection.ltr => OverlaySide.right,
      TextDirection.rtl => OverlaySide.left,
    };
    final across = switch (_bound && _inner == endSide) {
      true => SheetContent.boundCloseInset,
      false => DialogMetrics.closeInset,
    };
    final top = switch (_bound && _inner == OverlaySide.top) {
      true => SheetContent.boundCloseInset,
      false => DialogMetrics.closeInset,
    };
    return PositionedDirectional(
      top: top,
      end: across,
      child: DialogCloseMark(seed: '$seed|x'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final media = MediaQuery.maybeOf(context);
    final window = media?.size ?? Size.infinite;
    final sideways = !widget.side.vertical;
    final full = window.width >= DialogMetrics.phoneBreakpoint;
    final sideWidth =
        widget.width ??
        switch (full) {
          true => math.min(
            window.width * SheetContent.sideShare,
            SheetContent.maxSideWidth,
          ),
          false => window.width * SheetContent.sideShare,
        };
    final children = [
      for (final child in widget.children) ...[
        if (sideways && child is SheetFooter) const Spacer(),
        child,
      ],
    ];
    final page = Stack(
      fit: StackFit.passthrough,
      children: [
        Paper(
          stock: widget.stock,
          edge: _edge,
          tilt: false,
          rules: widget.rules,
          shadow: PaperShadow.none,
          seed: seed,
          padding: _padding(media?.padding.bottom ?? 0),
          child: Column(
            mainAxisSize: switch (sideways) {
              true => MainAxisSize.max,
              false => MainAxisSize.min,
            },
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DialogMetrics.gap,
            children: children,
          ),
        ),
        if (_bound && !PaperInk.calm(theme)) _binding(seed),
        if (widget.showCloseButton)
          _closeMark(seed, Directionality.of(context)),
      ],
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: widget.semanticLabel != null,
      label: widget.semanticLabel,
      child: DialogContentScope(
        closeMark: widget.showCloseButton,
        phone: !full,
        child: DefaultTextStyle.merge(
          style: theme.typography.interface(color: theme.colors.ink),
          child: ConstrainedBox(
            constraints: switch (sideways) {
              true => BoxConstraints.tightFor(width: sideWidth),
              false => BoxConstraints(
                maxHeight: window.height * SheetContent.edgeShare,
              ),
            },
            child: DecoratedBox(
              decoration: BoxDecoration(boxShadow: _shadow(theme)),
              position: DecorationPosition.background,
              child: page,
            ),
          ),
        ),
      ),
    );
  }
}
